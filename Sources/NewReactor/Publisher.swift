//
//  Publisher.swift
//  GoodReactor
//
//  Created by Filip Šašala on 28/08/2024.
//

import Foundation

public actor Publisher<Value: Sendable> {

    // MARK: - Variables

    internal var subscribers = NSPointerArray.weakObjects()

    // MARK: - Initialization

    public init() {}

}

// MARK: - Public

public extension Publisher {

    func send(_ value: Value) {
        eachSubscriber { await $0.receive(value: value) }
    }

    func finish() {
        eachSubscriber { await $0.finish() }
    }

}

// MARK: - Internal

internal extension Publisher {

    func connect(to subscriber: Subscriber<Value>) {
        subscribers.addObject(subscriber)
    }

}

// MARK: - Private

private extension Publisher {

    func eachSubscriber(_ action: @autoclosure @escaping () -> (Subscriber<Value>) async -> ()) {
        guard subscribers.count > 0 else { return }

        subscribers.removeNils()

        for index in 0..<subscribers.count {
            guard let subscriber = subscribers.object(at: index) as? Subscriber<Value> else { continue }
            let action = action()
            Task { await action(subscriber) }
        }
    }

}
