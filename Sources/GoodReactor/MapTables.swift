//
//  MapTables.swift
//  GoodReactor
//
//  Created by Filip Šašala on 27/08/2024.
//

import GoodLogger

internal enum MapTables {

    typealias AnyReactor = AnyObject

    static let state = WeakMapTable<AnyReactor, Any>()
    static let initialState = WeakMapTable<AnyReactor, Any>()
    static let destinations = WeakMapTable<AnyReactor, Any?>()
    static let runningEvents = WeakMapTable<AnyReactor, Set<EventIdentifier>>()
    static let subscriptions = WeakMapTable<AnyReactor, Set<AnyTask>>()
    static let stateStreams = WeakMapTable<AnyReactor, Any>()
    static let eventStreams = WeakMapTable<AnyReactor, Any>()
    static let loggers = WeakMapTable<AnyReactor, GoodLogger>()

    static let eventLocks = WeakMapTable<EventIdentifier, AsyncSemaphore>()

}
