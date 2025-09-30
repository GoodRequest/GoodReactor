//
//  ObservableModel.swift
//  GoodReactor
//
//  Created by Filip Šašala on 30/08/2024.
//

import GoodReactor
import Observation

final class EmptyObject {}

// MARK: - Example - Counter model using Observation framework

@available(iOS 17.0, *)
@Observable final class ObservableModel: Reactor {

    func transform() {
        subscribe {
            await ExternalTimer.shared.timePublisher
        } map: {
            Mutation.didChangeTime(seconds: $0)
        }
    }

    typealias Event = GoodReactor.Event<Action, Mutation, Destination>

    // MARK: Enums

    enum Action {
        case addOne
        case subtractOne
        case resetToZero
        case cascade
        case multipleRuns
        case hundredRuns
        case twiceHundredRuns
        case debounceTest
        case setCounter(Int)
    }

    enum Mutation {
        case didChangeTime(seconds: Int)
        case didAddOne
        case didReceiveValue(newValue: Int)
        case didAddOneWithDelay
        case doOneHalfOfTwoHundredRuns
    }

    // MARK: Destination

    var destination: Destination?

    enum Destination {}

    // MARK: State

    @Observable final class State {

        var counter: Int = 9
        var time: Int = 0
        var object: AnyObject = EmptyObject()

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

        case .action(.multipleRuns):
            run(event) {
                try? await Task.sleep(for: .seconds(1))
                return .didAddOneWithDelay
            }
            run(event) {
                try? await Task.sleep(for: .seconds(1))
                return .didAddOneWithDelay
            }
            run(event) {
                try? await Task.sleep(for: .seconds(1))
                return .didAddOneWithDelay
            }
            run(event) {
                try? await Task.sleep(for: .seconds(1))
                return .didAddOneWithDelay
            }
            run(event) {
                try? await Task.sleep(for: .seconds(1))
                return .didAddOneWithDelay
            }

        case .action(.hundredRuns):
            for _ in 0..<100 {
                run(event) {
                    try? await Task.sleep(for: .seconds(1))
                    return .didAddOneWithDelay
                }
            }

        case .action(.twiceHundredRuns):
            run(event) {
                return .doOneHalfOfTwoHundredRuns
            }
            run(event) {
                return .doOneHalfOfTwoHundredRuns
            }

        case .mutation(.doOneHalfOfTwoHundredRuns):
            for _ in 0..<100 {
                run(event) {
                    try? await Task.sleep(for: .seconds(1))
                    return .didAddOneWithDelay
                }
            }

        case .action(.debounceTest):
            let counterValue = state.counter

            debounce(duration: .milliseconds(500)) {
                return await self.asyncAddOne(oldValue: counterValue)
            }

        case .action(.setCounter(let newValue)):
            state.counter = newValue

        case .mutation(.didAddOne):
            state.counter += 1

            let counterValue = state.counter
            if counterValue < 10 {
                run(event) { await self.asyncAddOne(oldValue: counterValue) }
            }

        case .mutation(.didAddOneWithDelay):
            state.counter += 1

        case .mutation(.didReceiveValue(let newValue)):
            state.counter = newValue

        case .mutation(.didChangeTime(let seconds)):
            state.time = seconds

        case .destination:
            break
        }
    }

    // MARK: Async/side effects

    func asyncAddOne() async -> Mutation? {
        try? await Task.sleep(nanoseconds: UInt64(5e8)) // 500 ms
        return .didAddOneWithDelay
    }

    func asyncAddOne(oldValue: Int) async -> Mutation? {
        try? await Task.sleep(nanoseconds: UInt64(33e7)) // 330 ms

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

