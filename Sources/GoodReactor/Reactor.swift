//
//  Reactor.swift
//  GoodReactor
//
//  Created by Filip Šašala on 23/08/2024.
//

import AsyncAlgorithms
import Collections
import GoodLogger
import Observation

#if canImport(Combine)
import Combine
#endif

#if canImport(SwiftUI)
import SwiftUI
#endif

// MARK: - Reactor protocol

@MainActor @dynamicMemberLookup public protocol Reactor: AnyObject, Identifiable, Hashable {

    /// Internal events
    ///
    /// Used for actions invoked from an interaction with the UI.
    /// See ``send(action:)-4t47e``
    ///
    /// Example usage:
    /// ```swift
    /// enum Action {
    ///     case increment
    ///     case decrement
    /// }
    /// ```
    associatedtype Action: Sendable

    /// External events
    ///
    /// Used for mutations which are a response to an external event or a side effect,
    /// such as response to a request or result of an asynchronous action.
    ///
    /// Example usage:
    /// ```swift
    /// enum Mutation {
    ///     case timerDidFinish
    ///     case didReceiveProfile(UserProfile)
    /// }
    /// ```
    associatedtype Mutation: Sendable

    #warning("TODO: documentation")
    associatedtype Destination: Sendable

    var destination: Destination? { get set }

    /// State of the view
    ///
    /// ## In iOS 17+:
    /// Mark the state as an `@Observable` final class (from Observation framework).
    ///
    /// ```swift
    /// @Observable final class State {
    ///     var count: Int = 10
    ///}
    ///```
    ///
    /// ## In iOS 16 and earlier:
    /// Mark the state as a `struct` and add `ObservableObject` conformance to
    /// the entire Reactor model.
    ///
    /// ```swift
    /// final class SampleViewModel: Reactor, ObservableObject {
    ///     // ...
    ///     struct State {
    ///         var count: Int = 10
    ///     }
    ///     // ...
    /// }
    /// ```
    associatedtype State

    /// Logger used for logging reactor events
    static var logger: GoodLogger { get }

    /// Initial state of the reactor
    ///
    /// This is a separate instance from ``state-1ufdb``, created by calling
    /// ``makeInitialState()``.
    ///
    /// - note: Using `initialState` is discouraged and is provided only for
    /// migration/backwards compatibility reasons.
    ///
    /// - warning: Take caution when using object references inside ``State``,
    /// as they can point to an object that may get mutated after the creation of initialState.
    var initialState: State { get }

    /// Constructor for this reactor's logger. Gets called only once during the lifetime
    /// of a Reactor.
    ///
    /// Default logger is `OSLogLogger` in iOS 14 and newer, or
    /// `PrintLogger` in older iOS versions.
    ///
    /// - Returns: Logger used for logging reactor events. See `GoodLogger` package
    /// for more information.
    static func makeLogger() -> GoodLogger

    /// Constructor for this reactor's initial state.
    ///
    /// This function may get called twice (once for default state, once
    /// for ``initialState-9l2w6``). If you intend to use `initialState`, try to
    /// make sure the returned state is a deep copy and has no references to shared
    /// objects to prevent further mutability.
    /// - Returns: Initial state of the reactor
    func makeInitialState() -> State

    /// Creates subscriptions to external events, that supply mutations to this Reactor.
    ///
    /// Call ``subscribe(to:map:)`` inside this function to create subscriptions
    /// to data ``Publisher``-s outside of this Reactor.
    /// ```swift
    /// func transform() {
    ///     subscribe {
    ///         await ExternalTimer.shared.timePublisher
    ///     } map: {
    ///         Mutation.didChangeTime(seconds: $0)
    ///     }
    /// }
    /// ```
    ///
    /// This example will subscribe to an external ``Publisher`` that publishes
    /// current UNIX time every second.
    /// The result is mapped to a concrete mutation `didChangeTime` and
    /// the mutation is later processed in `reduce` function to change the state
    /// of the reactor.
    ///
    /// You can use multiple subscriptions to multiple external events.
    func transform()

    #if canImport(Combine)
    /// Creates subscriptions to external events, that supply events to this Reactor.
    ///
    /// You override this function to merge your custom publisher chains with
    /// a provided event publisher (in parameter).
    /// ```swift
    /// func transform(event: AnyPublisher<Event.Kind, Never>) -> AnyPublisher<Event.Kind, Never> {
    ///     return event
    ///         .merge(with: myCustomPublisher.map { .mutation(.changeValue($0)) }
    ///         .eraseToAnyPublisher()
    /// }
    /// ```
    func transform(event: AnyPublisher<Event.Kind, Never>) -> AnyPublisher<Event.Kind, Never>
    #endif
    
    /// Reducer for this reactor. Reducer takes the current state and event (action or
    /// mutation), mutates the state and decides on the next steps. This is the main
    /// "logic" block of the Reactor.
    ///
    /// Switch over the `event.kind` to see the exact event received. You should
    /// handle all possible events that this reactor may receive.
    ///
    /// To chain another action to this event, call ``run(_:_:)`` and supply
    /// the event that required an action, as well as the action closure itself.
    ///
    /// ```swift
    /// func reduce(state: inout State, event: Event) {
    ///     switch event.kind {
    ///     case .action(.increment):
    ///         state.counter += 1
    ///     case .action(.decrement):
    ///         state.counter -= 1
    ///     case .mutation(.timerDidFinish):
    ///         state.counter = 0
    ///     case .mutation(.didReceiveProfile(let userProfile):
    ///         state.counter = userProfile.counter
    ///         run(event) { await fetchProfilePhoto() }
    ///     }
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - state: State of the Reactor at the time when an event was registered.
    ///   - event: Wrapper containing the action or mutation received. See ``Event``.
    func reduce(state: inout State, event: Event)

}

// MARK: - Dynamic member lookup

public extension Reactor {

    #if canImport(SwiftUI)
    func bind<T>(_ member: KeyPath<State, T>, action: @escaping (T) -> Action) -> Binding<T> {
        Binding(get: {
            self.state[keyPath: member]
        }, set: { newValue in
            self.send(action: action(newValue))
        })
    }
    #endif

    subscript<T>(dynamicMember dynamicMember: KeyPath<State, T>) -> T {
        return state[keyPath: dynamicMember]
    }

    subscript<T>(dynamicMember dynamicMember: ReferenceWritableKeyPath<State, T>) -> T {
        return state[keyPath: dynamicMember]
    }

}

// MARK: - Default implementation

public extension Reactor {

    typealias Event = GoodReactor.Event<Action, Mutation, Destination>

    static var logger: GoodLogger {
        MapTables.loggers.forceCastedValue(forKey: self, default: makeLogger())
    }

    var state: State {
        get {
            MapTables.state.forceCastedValue(forKey: self, default: makeInitialState())
        }
        set {
            MapTables.state.setValue(newValue, forKey: self)
        }
    }

    var initialState: State {
        MapTables.initialState.forceCastedValue(forKey: self, default: makeInitialState())
    }

    static func makeLogger() -> GoodLogger {
        if #available(iOS 14, *) {
            OSLogLogger()
        } else {
            PrintLogger()
        }
    }

    func transform() {}

    #if canImport(Combine)
    func transform(event: AnyPublisher<Event.Kind, Never>) -> AnyPublisher<Event.Kind, Never> {
        return event
    }
    #endif

}

// MARK: - Public

public extension Reactor {

    typealias DebouncerResultHandler = (@Sendable () async -> Mutation?)

    /// Send an action to this Reactor. The Reactor will decide how to modify
    /// the ``State`` according to the implementation of ``reduce(state:event:)``
    /// function.
    ///
    /// - Parameter action: Action to process. See ``Action``.
    ///
    /// This is a "fire and forget" style of sending the action, as the action
    /// will be executed asynchronously in the background. There is no way
    /// to cancel the action after sending it.
    func send(action: Action) {
        let event = Event(kind: .action(action))
        _send(event: event)
    }

    /// Send an action to this Reactor. The Reactor will decide how to modify
    /// the ``State`` according to the implementation of ``reduce(state:event:)``
    /// function.
    ///
    /// - Parameter action: Action to process. See ``Action``.
    ///
    /// This is an asynchronous function that will resume once the action
    /// has completed all its side effects. You can cancel the action by cancelling the
    /// Task that has sent this action. Cancelling the task will not undo the changes
    /// to state that were already finished.
    ///
    /// - important: Depending on the action executed, processing an event may
    /// take a long time.
    func send(action: Action) async {
        let event = Event(kind: .action(action))
        await _sendAsync(event: event)
    }

    #warning("TODO: add documentation")
    func send(destination: Destination?) {
        self.destination = destination
    }

    /// Starts the Reactor - the Reactor starts listening to external events
    /// by calling the ``transform()-7ttgl`` function. If the Reactor
    /// uses Combine, subscribes the event stream and publishes the
    /// initial state.
    func start() {
        self.transform()

        #if canImport(Combine)
        self.makeCombineEventStream()
        #endif
    }

    /// Asynchronously runs a handler associated with an event. If handler returns a mutation,
    /// the entire event waits until the mutation is reduced before continuing.
    ///
    /// - Parameters:
    ///   - event: Event responsible for starting the asynchronous task.
    ///   - eventHandler: Asynchronous task to start, eg. a network request or database fetch.
    ///   This function should not have any side effects on this Reactor's state. Returns ``Mutation``
    ///   or `nil`, depending on whether any further action is neccessary.
    ///
    /// This function doesn't block.
    ///
    /// - important: Start async events only from ``reduce(state:event:)`` to ensure correct behaviour.
    /// - warning: This function is unavailable from asynchronous contexts. If you need to run multiple tasks
    /// concurrently, create a `TaskGroup` with ``_Concurrency/Task``s, use `async let` or consider using
    /// an external helper struct.
    /// - note: If you need to return multiple mutations from an asynchronous event, create a helper struct
    /// and supply mutations using a ``Publisher`` and ``subscribe(to:map:)``
    @available(*, noasync) func run(_ event: Event, @_implicitSelfCapture eventHandler: @autoclosure @escaping () -> @Sendable () async -> Mutation?) {
        let semaphore = MapTables.eventLocks[key: event.id, default: AsyncSemaphore(value: 0)]
        MapTables.runningEvents[key: self, default: []].insert(event.id)

        Task { @MainActor [weak self] in
            guard let self else { return }

            defer {
                MapTables.runningEvents[key: self, default: []].remove(event.id)
                semaphore.signal()
            }

            let mutation = await Task.detached(operation: eventHandler()).value

            guard !Task.isCancelled else {
                _debugLog(message: "Task cancelled")
                return
            }

            if let mutation {
                let mutationEvent = Event(kind: .mutation(mutation))
                await _sendAsync(event: mutationEvent)
            }
        }
    }
    
    /// Debounces calls to a function by ignoring repeated successive calls. If handler returns a mutation,
    /// the mutation will be executed once when debouncing is
    ///
    /// ## Usage
    /// ```swift
    /// debounce(duration: .seconds(1)) {
    ///     await sendDebouncedNetworkRequest()
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - duration: Time interval the debouncer will wait for any repeated calls.
    ///   - resultHandler: Function that will be called when there are no more
    ///   events to debounce and enough time has passed.
    ///   - file: Internal debouncer identifier macro, do not pass any value.
    ///   - line: Internal debouncer identifier macro, do not pass any value.
    ///   - column: Internal debouncer identifier macro, do not pass any value.
    ///
    /// This function doesn't block.
    ///
    /// - note: Each debouncer is identified by its location in source code. If you need to
    /// supply events to a debouncer from multiple locations, use an instance of a ``Debouncer``
    /// directly.
    func debounce(
        duration: DispatchTimeInterval,
        @_implicitSelfCapture resultHandler: @escaping DebouncerResultHandler,
        _ file: StaticString = #file,
        _ line: UInt = #line,
        _ column: UInt = #column
    ) {
        let debouncerIdentifier = DebouncerIdentifier(file, line, column)

        let localDebouncer: Debouncer<DebouncerResultHandler>
        if let debouncer = MapTables.debouncers[key: self, default: [:]][debouncerIdentifier] as? Debouncer<DebouncerResultHandler> {
            localDebouncer = debouncer
        } else {
            // create new debouncer
            localDebouncer = Debouncer<DebouncerResultHandler>(delay: duration, outputHandler: { @MainActor [weak self] resultHandler in
                guard let self else { return }

                let mutation = await Task.detached { await resultHandler() }.value

                guard !Task.isCancelled else {
                    _debugLog(message: "Debounce cancelled")
                    return
                }

                if let mutation {
                    let mutationEvent = Event(kind: .mutation(mutation))
                    _send(event: mutationEvent)
                }
            })

            MapTables.debouncers[key: self, default: [:]][debouncerIdentifier] = localDebouncer
        }

        Task {
            await localDebouncer.push(resultHandler)
        }
    }

    /// Create a new subscription to external event publisher for current reactor.
    ///
    /// The subscription is stored and kept active until the reactor is deallocated
    /// or a `finish` event is received.
    ///
    ///
    ///
    /// ## Usage
    /// ```swift
    /// func transform() {
    ///     subscribe {
    ///         externalValuePublisher
    ///     } map: {
    ///         .changeValue($0)
    ///     }
    /// }
    /// ```
    /// - Parameters:
    ///   - publisherProvider: Resolution of an external publisher of any type of value
    ///   - mapper: Map function mapping received values to this reactor's Mutations.
    ///
    /// - important: Call from the `transform` function. Remember to `start()`
    /// the reactor to properly initalize the subscriptions.
    func subscribe<Value: Sendable>(
        to publisherProvider: @escaping @autoclosure () -> @Sendable () async -> any Publisher<Value>,
        map mapper: @escaping @autoclosure () -> @Sendable (Value) async -> (Mutation)
    ) {
        let publisher = publisherProvider()
        let subscription = Task { [weak self] in
            let newSubscriber = Subscriber<Value>()
            await newSubscriber.subscribe(to: publisher())

            let map = mapper()
            for await value in newSubscriber {
                let mutation = await map(value)
                let event = Event(kind: .mutation(mutation))

                guard let self else { return }
                _send(event: event)
            }

            Self._debugLog(message: "Subscription finished")
        }

        subscription.store(in: &MapTables.subscriptions[key: self, default: []])
    }

}

// MARK: - Private

private extension Reactor {

    private static var name: String {
        String(describing: Self.self)
    }

    private func _send(event: Event) {
        _reduce(state: &state, event: event)
    }

    private func _sendAsync(event: Event) async {
        let eventId = event.id
        let semaphore = MapTables.eventLocks[key: event.id, default: AsyncSemaphore(value: 0)]

        _reduce(state: &state, event: event)

        if MapTables.runningEvents[key: self, default: []].contains(eventId) {
            try? await semaphore.waitUnlessCancelled()
        }
    }

    private func _reduce(state: inout State, event: Event) {
        if let self = self as? any ObservableObject,
           let objectWillChange = self.objectWillChange as? ObservableObjectPublisher {
            objectWillChange.send()
        }

        reduce(state: &state, event: event)

        #if canImport(Combine)
        _stateStream.send(state)
        #endif
    }

    private func _debugLog(message: String) {
        Self._debugLog(message: message)
    }

    private static func _debugLog(message: String) {
        logger.log(level: .debug, message: "[GoodReactor] \(Self.name) - \(message)", privacy: .auto)
    }

}

// MARK: - Combine

#if canImport(Combine)
import Combine

public extension Reactor {

    private var _stateStream: Combine.PassthroughSubject<State, Never> {
        MapTables.stateStreams.forceCastedValue(forKey: self, default: PassthroughSubject<State, Never>())
    }

    var stateStream: Combine.AnyPublisher<State, Never> {
        _stateStream.eraseToAnyPublisher()
    }

    var eventStream: Combine.PassthroughSubject<Event.Kind, Never> {
        MapTables.eventStreams.forceCastedValue(forKey: self, default: PassthroughSubject<Event.Kind, Never>())
    }

    private func makeCombineEventStream() {
        let eventStream = self.eventStream
        let transformedEventStream = transform(event: eventStream.eraseToAnyPublisher())

        let eventSubscriber = Subscriber<Event.Kind>()
        transformedEventStream.subscribe(eventSubscriber)

        let subscription = Task { [weak self] in
            for await eventKind in eventSubscriber {
                let event = Event(kind: eventKind)

                guard let self else { return }
                _send(event: event)
            }
        }

        subscription.store(in: &MapTables.subscriptions[key: self, default: []])

        _stateStream.send(initialState)
    }

}
#endif

// MARK: - Hashable & Identifiable

public extension Reactor {

    nonisolated var id: ObjectIdentifier {
        ObjectIdentifier(self)
    }

    nonisolated func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    nonisolated static func == (lhs: Self, rhs: Self) -> Bool {
        lhs === rhs
    }

}

// MARK: - Migration

public extension Reactor {

    @available(*, deprecated, message: "Call members directly from Reactor instead of using `currentState` property.")
    var currentState: State {
        state
    }

}
