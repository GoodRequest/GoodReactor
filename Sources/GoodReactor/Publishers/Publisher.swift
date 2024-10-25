//
//  Publisher.swift
//  GoodReactor
//
//  Created by Filip Šašala on 28/08/2024.
//

import Foundation

// MARK: - Publisher protocol

public protocol Publisher<Value>: Sendable {

    associatedtype Value: Sendable

    func send(_ value: Value) async
    func finish() async

    func connect(to subscriber: Subscriber<Value>) async

}

extension Publisher {

    public nonisolated func sendAsync(_ value: Value) {
        Task { await send(value) }
    }

    public nonisolated func finishAsync() {
        Task { await finish() }
    }

}
