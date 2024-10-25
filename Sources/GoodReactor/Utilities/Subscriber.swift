//
//  Subscriber.swift
//  GoodReactor
//
//  Created by Filip Šašala on 28/08/2024.
//

import Foundation
import Collections

public actor Subscriber<Value: Sendable>: AsyncSequence, AsyncIteratorProtocol {

    // MARK: - Typealiases

    public typealias AsyncIterator = Subscriber
    public typealias Element = Value

    // MARK: - Variables

    private let semaphore = AsyncSemaphore(value: 0)

    private var valueQueue = Deque<Value>()
    private var publisher: Publisher<Value>?

    // MARK: - Initialization

    public init() {}

    // MARK: - Iterator

    nonisolated public func makeAsyncIterator() -> Subscriber<Value> {
        self
    }

    public func next() async -> Value? {
        do {
            try await semaphore.waitUnlessCancelled()
        } catch {
            return nil
        }

        return valueQueue.popFirst()
    }

}

// MARK: - Public

public extension Subscriber {

    func subscribe(to publisher: Publisher<Value>) async {
        await publisher.connect(to: self)
    }

}

// MARK: - Internal

internal extension Subscriber {

    func receive(value: Value) {
        valueQueue.append(value)
        semaphore.signal()
    }

    func finish() {
        semaphore.signal()
    }

}

// MARK: - Combine interoperability

#if canImport(Combine)
import Combine

extension Subscriber: Combine.Subscriber {

    public typealias Input = Value
    public typealias Failure = Never

    nonisolated public func receive(subscription: any Subscription) {
        subscription.request(.unlimited)
    }

    nonisolated public func receive(_ input: Value) -> Subscribers.Demand {
        Task { await self.receive(value: input) }
        return .unlimited
    }

    nonisolated public func receive(completion: Subscribers.Completion<Never>) {
        Task { await self.finish() }
    }

}

#endif
