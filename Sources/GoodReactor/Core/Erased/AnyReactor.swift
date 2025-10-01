//
//  AnyReactor.swift
//  GoodReactor
//
//  Created by Filip Šašala on 24/09/2025.
//

import Observation

#if canImport(SwiftUI)
import SwiftUI
#endif

/// A type-erased, observable wrapper around a ``Reactor``.
///
/// Hide a Reactor’s concrete type (including its `Mutation`) while keeping the
/// public interface needed to drive UI and navigation. This helps decouple views,
/// store heterogeneous reactors, and expose a stable API surface across modules.
///
/// On type-erased `Mutation`:
/// When one view is reused with multiple view models that share the same UI, actions, and state
/// but require slightly different internal behavior, each view model can keep its own concrete
/// `Mutation` type while the view works with a single `AnyReactor`. The view remains agnostic to
/// those internal differences.
///
/// Behavior:
/// - State is accessed dynamically and mutated by reducing events on a concrete underlying reactor.
/// - Lifecycle: external subscriptions start automatically when `AnyReactor` is initialized (by `start()`-ing the base reactor).
/// - Events from `send(action:)`, `send(action:) async`, and `send(destination:)` are forwarded to the base reactor.
///
/// Example:
/// ```swift
/// struct ProfileView: View {
///     @ViewModel var reactor: AnyReactor = ProfileViewModel().eraseToAnyReactor()
///
///     var body: some View {
///         VStack {
///             Text(reactor.name)              // dynamic access into state
///             if reactor.isLoading { ProgressView() }
///             Button("Reload") { reactor.send(action: .reload) }
///         }
///     }
/// }
/// ```
///
/// - Note: Mutation type is intentionally erased. If you need access to mutations, prefer using concrete Reactor type instead.
@available(iOS 17.0, macOS 14.0, *)
@MainActor @Observable @dynamicMemberLookup public final class AnyReactor<WrappedAction: Sendable, WrappedDestination: Sendable, WrappedState>: Reactor {

    // MARK: - Type aliases

    public typealias Action = WrappedAction
    public typealias Mutation = AnyMutation
    public typealias Destination = WrappedDestination
    public typealias State = WrappedState

    private let _box: any AnyReactorBoxProtocol<Action, Destination, State>

    // MARK: - Initialization

    public init<R: Reactor>(_ base: R) where R.Action == Action, R.Destination == Destination, R.State == State {
        self._box = AnyReactorBox(base)
        base.start()
    }

}

// MARK: - Dynamic member lookup

@available(iOS 17.0, macOS 14.0, *)
public extension AnyReactor {

    #if canImport(SwiftUI)
    func bind<T>(_ member: KeyPath<WrappedState, T>, action: @escaping (T) -> Action) -> Binding<T> {
        Binding(get: {
            self._box.state[keyPath: member]
        }, set: { newValue in
            self._box.send(action: action(newValue))
        })
    }
    #endif

    subscript<T>(dynamicMember keyPath: KeyPath<State, T>) -> T {
        _box.state[keyPath: keyPath]
    }

    subscript<T>(dynamicMember keyPath: ReferenceWritableKeyPath<State, T>) -> T {
        _box.state[keyPath: keyPath]
    }

}

// MARK: - Reactor

@available(iOS 17.0, macOS 14.0, *)
public extension AnyReactor {

    func makeInitialState() -> State {
        _box.makeInitialState()
    }

    func transform() {
        _box.transform()
    }

    var destination: Destination? {
        get {
            _box.destination
        }
        set {
            _box.send(destination: newValue)
        }
    }

    var state: State {
        _box.state
    }

    func reduce(state: inout WrappedState, event: Event<Action, Mutation, Destination>) {
        _box.reduceAny(state: &state, event: event)
    }

}

// MARK: - Mirror

@available(iOS 17.0, macOS 14.0, *)
public extension AnyReactor {

    func send(action: Action) {
        _box.send(action: action)
    }

    func send(action: Action) async {
        await _box.send(action: action)
    }

    func send(destination: Destination?) {
        _box.send(destination: destination)
    }

}

// MARK: - Eraser

@available(iOS 17.0, macOS 14.0, *)
public extension Reactor {

    func eraseToAnyReactor() -> AnyReactor<Action, Destination, State> {
        AnyReactor(self)
    }

}

