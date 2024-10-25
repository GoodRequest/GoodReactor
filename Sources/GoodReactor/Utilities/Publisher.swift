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

    nonisolated func sendAsync(_ value: Value) {
        Task { await send(value) }
    }

    nonisolated func finishAsync() {
        Task { await finish() }
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

// MARK: - Property wrapper

public typealias Broadcast = GoodReactor.Published

@propertyWrapper public final class Published<Value: Sendable> {

    public var wrappedValue: Value {
        didSet {
            projectedValue.sendAsync(wrappedValue)
        }
    }

    public var projectedValue: Publisher<Value>

    public init(wrappedValue: Value, sendInitialValue: Bool = false) {
        self.wrappedValue = wrappedValue
        self.projectedValue = Publisher<Value>()

        if sendInitialValue {
            projectedValue.sendAsync(wrappedValue)
        }
    }

    deinit {
        projectedValue.finishAsync()
    }

}
