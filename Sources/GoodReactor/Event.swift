//
//  Event.swift
//  GoodReactor
//
//  Created by Filip Šašala on 27/08/2024.
//

import Foundation

// MARK: - Event

public final class Event<A, M, D>: Sendable where A: Sendable, M: Sendable, D: Sendable {

    public enum Kind: Sendable {
        case action(A)
        case mutation(M)
        case destination(D?)
    }

    internal let id: EventIdentifier
    public let kind: Event.Kind

    internal init(kind: Event.Kind) {
        self.id = EventIdentifier()
        self.kind = kind
    }

    convenience public init(destination: D?) {
        self.init(kind: .destination(destination))
    }

}

// MARK: - Event task counter

struct EventTaskCounter: Sendable {

    var events: [EventIdentifier: Int] = [:]
    
    /// Checks if any tasks are running for provided event
    /// - Parameter identifier: Event to check
    /// - Returns: `true` if any tasks are running, `false` otherwise
    func tasksActive(forEvent identifier: EventIdentifier) -> Bool {
        return events.keys.contains(identifier)
    }
    
    /// Increments task counter for provided event
    /// - Parameter identifier: Event starting a new task
    mutating func newTask(eventId identifier: EventIdentifier) {
        events[identifier] = (events[identifier] ?? 0) + 1
    }
    
    /// Decrements task counter for provided event
    /// - Parameter identifier: Event stopping the task
    /// - Returns: Number of remaining tasks
    mutating func stopTask(eventId identifier: EventIdentifier) -> Int {
        let taskCount = events[identifier] ?? 0
        let newTaskCount = taskCount - 1

        events[identifier] = newTaskCount

        if newTaskCount < 1 {
            events.removeValue(forKey: identifier)
        }

        return newTaskCount
    }

}
