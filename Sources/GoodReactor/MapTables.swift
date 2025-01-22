//
//  MapTables.swift
//  GoodReactor
//
//  Created by Filip Šašala on 27/08/2024.
//

import GoodLogger

internal enum MapTables {

    typealias AnyReactor = AnyObject

    // State of a reactor
    static let state = WeakMapTable<AnyReactor, Any>()

    // Initial state of a reactor
    static let initialState = WeakMapTable<AnyReactor, Any>()

    // Number of currently running asynchronous tasks for an event of a reactor
    static let runningEvents = WeakMapTable<AnyReactor, Set<EventIdentifier>>()

    // Subscriptions of a reactor (new way)
    static let subscriptions = WeakMapTable<AnyReactor, Set<AnyTask>>()

    // Debouncers of a reactor
    static let debouncers = WeakMapTable<AnyReactor, Dictionary<DebouncerIdentifier, Any>>()

    // State stream cancellable (Combine)
    static let stateStreams = WeakMapTable<AnyReactor, Any>()

    // Event stream cancellable (Combine)
    static let eventStreams = WeakMapTable<AnyReactor, Any>()

    // Logger of a reactor
    static let loggers = WeakMapTable<AnyReactor, GoodLogger>()

    // Semaphore lock of an event (does not matter which reactor it's running on)
    static let eventLocks = WeakMapTable<EventIdentifier, AsyncSemaphore>()

}
