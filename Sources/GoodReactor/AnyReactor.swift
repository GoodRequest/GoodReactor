//
//  AnyReactor.swift
//  GoodReactor
//
//  Created by Filip Šašala on 24/09/2025.
//

import Observation

@available(iOS 17.0, macOS 14.0, *)
@MainActor @Observable @dynamicMemberLookup public final class AnyReactor<WrappedAction: Sendable, WrappedMutation: Sendable, WrappedDestination: Sendable, WrappedState>: Reactor {

    // MARK: - Type aliases

    public typealias Action = WrappedAction
    public typealias Mutation = WrappedMutation
    public typealias Destination = WrappedDestination
    public typealias State = WrappedState

    // MARK: - Forwarders

    private let _getState: () -> State
    private let _setState: (State) -> ()
    private let _initialStateBuilder: () -> State
    private let _sendAction: (Action) -> ()
    private let _sendActionAsync: (Action) async -> ()
    private let _getDestination: () -> Destination?
    private let _sendDestination: (Destination?) -> ()
    private let _reduce: (inout State, Event<WrappedAction, WrappedMutation, WrappedDestination>) -> ()
    private let _transform: () -> ()

    // MARK: - Initialization

    public init<R: Reactor>(_ base: R) where
        R.Action == Action,
        R.Mutation == Mutation,
        R.Destination == Destination,
        R.State == State
    {
        self._getState = { base.state }
        self._setState = { base.state = $0 }
        self._initialStateBuilder = { base.makeInitialState() }
        self._sendAction = { base.send(action: $0) }
        self._sendActionAsync = { await base.send(action: $0) }
        self._getDestination = { base.destination }
        self._sendDestination = { base.send(destination: $0) }
        self._reduce = { base.reduce(state: &$0, event: $1) }
        self._transform = { base.transform() }
    }

}

// MARK: - Dynamic member lookup

@available(iOS 17.0, macOS 14.0, *)
public extension AnyReactor {

    subscript<T>(dynamicMember keyPath: KeyPath<State, T>) -> T {
        _getState()[keyPath: keyPath]
    }

    subscript<T>(dynamicMember keyPath: ReferenceWritableKeyPath<State, T>) -> T {
        _getState()[keyPath: keyPath]
    }

}

// MARK: - Reactor

@available(iOS 17.0, macOS 14.0, *)
public extension AnyReactor {

    func makeInitialState() -> State {
        _initialStateBuilder()
    }

    func transform() {
        _transform()
    }

    func reduce(state: inout State, event: Event<WrappedAction, WrappedMutation, WrappedDestination>) {
        _reduce(&state, event)
    }

    var destination: Destination? {
        get {
            _getDestination()
        }
        set {
            _sendDestination(newValue)
        }
    }

    var initialState: State {
        _initialStateBuilder()
    }

}

// MARK: - Mirror

@available(iOS 17.0, macOS 14.0, *)
public extension AnyReactor {

    func send(action: Action) {
        _sendAction(action)
    }

    func send(action: Action) async {
        await _sendActionAsync(action)
    }

    func send(destination: Destination?) {
        _sendDestination(destination)
    }

}

// MARK: - Eraser

@available(iOS 17.0, macOS 14.0, *)
public extension Reactor {

    func eraseToAnyReactor() -> AnyReactor<Action, Mutation, Destination, State> {
        AnyReactor(self)
    }

}
