//
//  EventTaskCounter.swift
//  GoodReactor
//
//  Created by Filip Šašala on 01/10/2025.
//

internal struct EventTaskCounter: Sendable {

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
        events[identifier] = events[identifier, default: 0] + 1
    }
    
    /// Decrements task counter for provided event
    /// - Parameter identifier: Event stopping the task
    /// - Returns: Number of remaining tasks
    mutating func stopTask(eventId identifier: EventIdentifier) -> Int {
        let taskCount = events[identifier, default: 0]
        let newTaskCount = taskCount - 1

        events[identifier] = newTaskCount

        if newTaskCount < 1 {
            events.removeValue(forKey: identifier)
        }

        return newTaskCount
    }

}
