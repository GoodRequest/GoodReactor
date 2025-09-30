//
//  MapTables.swift
//  GoodReactor
//
//  Created by Filip Šašala on 27/08/2024.
//

internal enum MapTables {

    internal typealias ReactorType = AnyObject

    // State of a reactor
    static let state = WeakMapTable<ReactorType, Any>()

    // Initial state of a reactor
    static let initialState = WeakMapTable<ReactorType, Any>()

    // Number of currently running asynchronous tasks for an event of a reactor
    static let runningEvents = WeakMapTable<ReactorType, EventTaskCounter>()

    // Subscriptions of a reactor (new way)
    static let subscriptions = WeakMapTable<ReactorType, Set<AnyTask>>()

    // Debouncers of a reactor
    static let debouncers = WeakMapTable<ReactorType, Dictionary<DebouncerIdentifier, Any>>()

    // State stream cancellable (Combine)
    static let stateStreams = WeakMapTable<ReactorType, Any>()

    // Event stream cancellable (Combine)
    static let eventStreams = WeakMapTable<ReactorType, Any>()

    // Logger of a reactor
    static let loggers = WeakMapTable<ReactorType, ReactorLogger>()

    // Semaphore lock of an event (does not matter which reactor it's running on)
    static let eventLocks = WeakMapTable<EventIdentifier, AsyncSemaphore>()

}
