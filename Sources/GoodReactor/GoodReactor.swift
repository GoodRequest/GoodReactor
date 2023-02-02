//
//  Reactor.swift
//  Gopass
//
//  Created by Dominik Pethö on 8/13/20.
//  Copyright © 2020 GoodRequest. All rights reserved.
//

import Foundation
import Combine
import CombineExt
import UIKit

///GoodCoordinator is used for managing navigation flow and data flow between different parts of an app.
///It is a generic class that takes a Step type as its generic parameter.
@available(iOS 13.0, *)
open class GoodCoordinator<Step>: NSObject {

    ///`Set` of `AnyCancellable` objects used to keep track of any cancellables created while using `Combine`.
    open var cancellables: Set<AnyCancellable> = Set()

    ///Used to establish the coordinator hierarchy.
    open var parentCoordinator: GoodCoordinator<Step>?
    @Published open var step: Step?

    public init(parentCoordinator: GoodCoordinator<Step>? = nil) {
        self.parentCoordinator = parentCoordinator
    }

    /// Search for the first matching coordinator in hierarchy
    /// Need to setup parent coordinator to establish the coordinator hierarchy
    public func firstCoordinatorOfType<T>(type: T.Type) -> T? {
        if let thisCoordinator = self as? T {
            return thisCoordinator
        } else if let parentCoordinator = parentCoordinator {
            return parentCoordinator.firstCoordinatorOfType(type: T.self)
        }
        return nil
    }

    /// Search for the last matching coordinator in hierarchy
    /// Need to setup parent coordinator to establish the coordinator hierarchy
    public func lastCoordinatorOfType<T>(type: T.Type) -> T? {
        if let parentCoordinator = parentCoordinator,
           let lastResult = parentCoordinator.lastCoordinatorOfType(type: T.self) {
            return lastResult
        } else {
            return self as? T
        }
    }

}

@available(iOS 13.0, *)
private enum MapTables {

    static let cancellables = WeakMapTable<AnyObject, Set<AnyCancellable>>()
    static let currentState = WeakMapTable<AnyObject, Any>()
    static let action = WeakMapTable<AnyObject, AnyObject>()
    static let state = WeakMapTable<AnyObject, AnyObject>()

}

@available(iOS 13.0, *)
public protocol GoodReactor: AnyObject {

    /// An action represents user actions.
    associatedtype Action

    /// A mutation represents state changes.
    associatedtype Mutation = Action

    /// A State represents the current state of a view.
    associatedtype State

    /// A property represents the the steps navigations
    associatedtype Stepper

    /// The action from the view. Bind user inputs to this subject.
    var action: PassthroughSubject<Action, Never> { get }

    /// The initial state.
    var initialState: State { get }

    /// The current state. This value is changed just after the state stream emits a new state.
    var currentState: State { get }

    /// The state stream. Use this observable to observe the state changes.
    var state: AnyPublisher<State, Never> { get }

    /// The instance of coordinator.
    var coordinator: GoodCoordinator<Stepper> { get }

    /// Transforms the action. Use this function to combine with other observables. This method is
    /// called once before the state stream is created.
    func transform(action: AnyPublisher<Action, Never>) -> AnyPublisher<Action, Never>

    /// Commits mutation from the action. This is the best place to perform side-effects such as
    /// async tasks.
    func mutate(action: Action) -> AnyPublisher<Mutation, Never>

    /// Transforms the mutation stream. Implement this method to transform or combine with other
    /// observables. This method is called once before the state stream is created.
    func transform(mutation: AnyPublisher<Mutation, Never>) -> AnyPublisher<Mutation, Never>

    /// Generates a new state with the previous state and the action. It should be purely functional
    /// so it should not perform any side-effects here. This method is called every time when the
    /// mutation is committed.
    func reduce(state: State, mutation: Mutation) -> State

    /// Transforms the state stream. Use this function to perform side-effects such as logging. This
    /// method is called once after the state stream is created.
    func transform(state: AnyPublisher<State, Never>) -> AnyPublisher<State, Never>

    /// Commit navigation from the action. This is the best place to navigate between screens
    func navigate(action: Action) -> Stepper?

}

// MARK: - Associated Object Keys

private var configKey = "config"
private var actionKey = "action"
private var currentStateKey = "currentState"
private var stateKey = "state"
private var cancellablesKey = "cancellables"
private var isStubEnabledKey = "isStubEnabled"
private var stubKey = "stub"

// MARK: - Default Implementations

@available(iOS 13.0, *)
public extension GoodReactor {

    internal(set) var currentState: State {
        get { MapTables.currentState.forceCastedValue(forKey: self, default: initialState) }
        set { MapTables.currentState.setValue(newValue, forKey: self) }
    }

    private var _state: AnyPublisher<State, Never> {
        MapTables.state.forceCastedValue(forKey: self, default: createStateStream())
    }

    var state: AnyPublisher<State, Never> {
        _state
    }

    var actionPublisher: PassthroughSubject<Action, Never> {
        MapTables.action.forceCastedValue(forKey: self, default: .init())
    }

    var action: PassthroughSubject<Action, Never> {
        _ = self.state
        return actionPublisher
    }

    fileprivate var cancellables: Set<AnyCancellable> {
        get { MapTables.cancellables.value(forKey: self, default: .init()) }
        set { MapTables.cancellables.setValue(newValue, forKey: self) }
    }

    func createStateStream() -> AnyPublisher<State, Never> {
        let action = self.actionPublisher.receive(on: DispatchQueue.main).eraseToAnyPublisher()

        let mutation = self.transform(action: action)
            .flatMap { [weak self] action -> AnyPublisher<Mutation, Never> in
                guard let `self` = self else { return Empty().eraseToAnyPublisher() }
                if let step = self.navigate(action: action) {
                    self.coordinator.step = step
                }
                return self.mutate(action: action).catch { _ in Empty() }.eraseToAnyPublisher()
            }
        .eraseToAnyPublisher()

        let transformedMutation = self.transform(mutation: mutation)
        let state = transformedMutation
            .scan(self.initialState) { [weak self] state, mutation -> State in
                guard let `self` = self else { return state }
                return self.reduce(state: state, mutation: mutation)
            }
            .catch { _ in Empty<Self.State, Never>().eraseToAnyPublisher() }
            .prepend(self.initialState)
            .eraseToAnyPublisher()

        let transformedState = self.transform(state: state)
            .handleEvents(receiveOutput: { [weak self] state in
                self?.currentState = state
            })
            .share(replay: 1)

        transformedState.sink { _ in }.store(in: &cancellables)

        return transformedState
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    func transform(action: AnyPublisher<Action, Never>) -> AnyPublisher<Action, Never> {
        return action
    }

    func mutate(action: Action) -> AnyPublisher<Mutation, Never> {
        return Empty().eraseToAnyPublisher()
    }

    func transform(mutation: AnyPublisher<Mutation, Never>) -> AnyPublisher<Mutation, Never> {
        return mutation
    }

    func reduce(state: State, mutation: Mutation) -> State {
        return state
    }

    func transform(state: AnyPublisher<State, Never>) -> AnyPublisher<State, Never> {
        return state
    }

    func send(event: Action) {
        action.send(event)
    }

}

@available(iOS 13.0, *)
extension GoodReactor where Action == Mutation {

    func mutate(action: Action) -> AnyPublisher<Mutation, Never> {
        return Just(action).eraseToAnyPublisher()
    }

}
