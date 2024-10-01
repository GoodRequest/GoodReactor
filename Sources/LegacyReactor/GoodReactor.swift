//
//  GoodReactor.swift
//
//  Created by Dominik Pethö on 8/13/20.
//  Copyright © 2020 GoodRequest. All rights reserved.
//

import Foundation
import Combine
import CombineExt
import SwiftUI

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

/// The `GoodReactor` is responsible for managing the view's state, as well as handling user actions and application navigation.
/// Defines a set of methods and properties that allow  specify how the application state changes in response to user actions.
@available(iOS 13.0, *)
public protocol GoodReactor: AnyObject, ObservableObject {

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

nonisolated(unsafe) private var configKey = "config"
nonisolated(unsafe) private var actionKey = "action"
nonisolated(unsafe) private var currentStateKey = "currentState"
nonisolated(unsafe) private var stateKey = "state"
nonisolated(unsafe) private var cancellablesKey = "cancellables"
nonisolated(unsafe) private var isStubEnabledKey = "isStubEnabled"
nonisolated(unsafe) private var stubKey = "stub"

// MARK: - Default Implementations

@available(iOS 13.0, *)
public extension GoodReactor where Self.ObjectWillChangePublisher == ObservableObjectPublisher {

    var currentState: State {
        get { MapTables.currentState.forceCastedValue(forKey: self, default: initialState) }
        set {
            objectWillChange.send()
            MapTables.currentState.setValue(newValue, forKey: self)
        }
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

    /// Initializes the reactive state of the `GoodReactor` instance and begins the reactive flow.
    /// - Note: This method should be called within the `init()` method of the `GoodReactor` instance.
    func start() {
        _ = self.state
    }

    /// Creates a publisher that emits the current state and then updates the state with new mutations from actions.
    /// The publisher will always emit at least one value: the `initial` state of the store.
    ///
    /// - Returns: A publisher that emits the current state and any subsequent state changes.
    func createStateStream() -> AnyPublisher<State, Never> {
        let action = self.actionPublisher.receive(on: DispatchQueue.main).eraseToAnyPublisher()

        let mutation = self.transform(action: action)
            .flatMap { [weak self] action -> AnyPublisher<Mutation, Never> in
                guard let `self` = self else { return Empty().eraseToAnyPublisher() }
                if let step = self.navigate(action: action) {
                    self.coordinator.step = step
                }
                return self.mutate(action: action).eraseToAnyPublisher()
            }
        .eraseToAnyPublisher()

        let transformedMutation = self.transform(mutation: mutation)
        let state = transformedMutation
            .scan(self.initialState) { [weak self] state, mutation -> State in
                guard let `self` = self else { return state }
                return self.reduce(state: state, mutation: mutation)
            }
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

    /// Sends an action to the `action` publisher.
    /// This function is used to trigger a state update in the app by sending an action that corresponds to a specific user interaction or event.
    /// - Parameter action: The action to be sent to the `action` publisher.
    func send(action: Action) {
        self.action.send(action)
    }

    /// This function is used to trigger a state update in the app by sending an action that corresponds to a specific user interaction or event,
    /// while also waiting for a specific state condition to be met.
    /// The `while` closure is used to check the state at every update and determine whether the task should continue to wait or resume.
    /// - Parameters:
    ///   - action: The action to be sent to the `action` publisher.
    ///   - while: A closure that takes a `State` argument and returns a `Bool`. The task will continue to wait while this closure returns `true` for the current state.
    /// - Note: This function is asynchronous and should be called with the `await` keyword.
    func send(action: Action, `while`: @escaping (State) -> Bool) async {
        self.send(action: action)

        await withCheckedContinuation { [weak self] (continuation: CheckedContinuation<Void, Never>) in
            guard let self = self else { return }

            var cancelled = false
            self.state
                .dropFirst()
                .filter { !`while`($0) }
                .subscribe(on: DispatchQueue.main)
                .handleEvents(receiveCancel: {
                    if !cancelled {
                        continuation.resume()
                    }
                })
                .prefix(1)
                .sink { _ in
                    continuation.resume()
                    cancelled = true
                }
                .store(in: &self.cancellables)
        }
    }

    // MARK: - Binding

    /// Returns a binding to a local state derived from the global state and an action to send the local state to the view.
    /// - Parameters:
    ///   - get: A closure that projects the global state to a local state.
    ///   - localStateToViewAction: A closure that takes the local state as input and returns the action to send it to the view.
    /// - Returns: A binding to the local state.
    @MainActor func binding<LocalState>(
        get: @escaping (State) -> LocalState,
        send localStateToViewAction: @escaping (LocalState) -> Action
    ) -> Binding<LocalState> {
        ObservedObject(wrappedValue: self)
            .projectedValue[get: .init(rawValue: get), send: .init(rawValue: localStateToViewAction)]
    }

    /// Returns a binding to a local state derived from the global state and a given action to send to the view.
    /// - Parameters:
    ///   - get: A closure that projects the global state to a local state.
    ///   - action: The action to send to the view when the local state changes.
    /// - Returns: A binding to the local state.
    @MainActor func binding<LocalState>(
        get: @escaping (State) -> LocalState,
        send action: Action
    ) -> Binding<LocalState> {
        self.binding(get: get, send: { _ in action })
    }

    /// Subscript that allows getting and setting a local state derived from the global state, and sending an action to the view.
    /// - Parameters:
    ///   - state: A hashable wrapper containing a closure that projects the global state to a local state.
    ///   - action: A hashable wrapper containing a closure that takes the local state as input and returns the action to send it to the view.
    /// - Returns: The local state.
    private subscript<LocalState>(
        get state: HashableWrapper<(State) -> LocalState>,
        send action: HashableWrapper<(LocalState) -> Action>
    ) -> LocalState {
        get { state.rawValue(self.currentState) }
        set { self.send(action: action.rawValue(newValue)) }
    }

}

@available(iOS 13.0, *)
extension GoodReactor where Action == Mutation {

    func mutate(action: Action) -> AnyPublisher<Mutation, Never> {
        return Just(action).eraseToAnyPublisher()
    }

}

/// A generic struct that wraps a value and conforms to the `Hashable` protocol.
/// - Parameter Value: The generic type of the value being wrapped.
private struct HashableWrapper<Value>: Hashable {

    let rawValue: Value
    static func == (lhs: Self, rhs: Self) -> Bool { false }
    func hash(into hasher: inout Hasher) {}

}
