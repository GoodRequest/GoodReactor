//
//  ReplayPublisher.swift
//  GoodReactor
//
//  Created by Filip Šašala on 25/10/2024.
//

import Foundation

public actor ReplayPublisher<Value: Sendable>: Publisher {

    private let upstream: any Publisher<Value>
    private(set) public var lastValue: Value? = nil

    init(replaying upstream: any Publisher<Value>) {
        self.upstream = upstream
    }

    public func send(_ value: Value) async {
        self.lastValue = value
        await upstream.send(value)
    }

    public func finish() async {
        await upstream.finish()
    }

}

// MARK: - Connecting

public extension ReplayPublisher {

    func connect(to subscriber: Subscriber<Value>) async {
        await upstream.connect(to: subscriber)

        if let lastValue {
            await subscriber.receive(value: lastValue)
        }
    }

}
