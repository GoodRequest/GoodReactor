//
//  LegacyModel.swift
//  GoodReactor
//
//  Created by Filip Šašala on 30/08/2024.
//

import NewReactor
import SwiftUI

// MARK: - Example - Counter model using ObservableObject API

@available(iOS 17.0, *)
final class LegacyModel: Reactor, ObservableObject {

    func transform() {
        subscribe {
            await ExternalTimer.shared.timePublisher
        } map: {
            Mutation.didChangeTime(seconds: $0)
        }
    }

    typealias Event = NewReactor.Event<Action, Mutation>

    // MARK: Enums

    enum Action {
        case addOne
        case subtractOne
        case resetToZero
        case cascade
    }

    enum Mutation {
        case didChangeTime(seconds: Int)
        case didAddOne
        case didReceiveValue(newValue: Int)
    }

    // MARK: State

    struct State: Sendable {

        var counter: Int = 9
        var time: Int = 0

    }

    // MARK: Initialization

    func makeInitialState() -> State {
        State()
    }

    // MARK: Reactive

    func reduce(state: inout State, event: Event) {
        switch event.kind {
        case .action(.addOne):
            state.counter += 1

        case .action(.subtractOne):
            state.counter -= 1

        case .action(.resetToZero):
            run(event) { await self.asyncResetToZero() }

        case .action(.cascade):
            let oldValue = state.counter
            run(event) { await self.asyncAddOne(oldValue: oldValue) }

        case .mutation(.didAddOne):
            state.counter += 1

            let counterValue = state.counter
            if counterValue < 10 {
                run(event) { await self.asyncAddOne(oldValue: counterValue) }
            }

        case .mutation(.didReceiveValue(let newValue)):
            state.counter = newValue

        case .mutation(.didChangeTime(let seconds)):
            state.time = seconds
        }
    }

    // MARK: Async/side effects

    func asyncAddOne(oldValue: Int) async -> Mutation? {
        try? await Task.sleep(nanoseconds: UInt64(33e7))

        if oldValue < 10 {
            return .didAddOne
        } else {
            return .none
        }
    }

    func asyncResetToZero() async -> Mutation {
        try? await Task.sleep(nanoseconds: UInt64(1e9))
        return .didReceiveValue(newValue: 0)
    }

    func asyncResetToTen() async -> Mutation {
        try? await Task.sleep(nanoseconds: UInt64(1e9))
        return .didReceiveValue(newValue: 10)
    }

}
