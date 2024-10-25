//
//  Broadcast.swift
//  GoodReactor
//
//  Created by Filip Šašala on 25/10/2024.
//


@propertyWrapper public final class Broadcast<Value: Sendable> {

    public var wrappedValue: Value {
        didSet {
            projectedValue.sendAsync(wrappedValue)
        }
    }

    public var projectedValue: any Publisher<Value>

    public init(wrappedValue: Value, replayLastValue: Bool = false) {
        self.wrappedValue = wrappedValue

        if replayLastValue {
            self.projectedValue = ReplayPublisher<Value>(replaying: PassthroughPublisher())
        } else {
            self.projectedValue = PassthroughPublisher<Value>()
        }
    }

    deinit {
        projectedValue.finishAsync()
    }

}
