//
//  AnyReactorTests.swift
//  GoodReactor
//
//  Created by Filip Šašala on 01/10/2025.
//

import XCTest
@testable import GoodReactor

import Combine
import SwiftUI

@available(iOS 17.0, macOS 14.0, *)
final class AnyReactorTests: XCTestCase {

    @MainActor func testSendAction() {
        let model = AnyReactor(ObservableModel())

        model.send(action: .addOne)

        XCTAssertEqual(model.initialState.counter, 9, "Initial state mutated")
        XCTAssertEqual(model.counter, 10, "Sending action failed")
    }

    @MainActor func testInitialState() {
        let model = AnyReactor(ObservableModel())

        XCTAssertEqual(model.initialState.counter, 9, "Invalid initial state")
        XCTAssertEqual(model.counter, 9, "Invalid initial state")

        XCTAssertNotIdentical(model.state, model.initialState, "Initial state is NOT A COPY but a reference!")
        XCTAssertNotIdentical(model.object, model.initialState.object, "Current state has a reference to initial state with possible mutations!")
    }

    @MainActor func testActionMutation() async throws {
        let model = AnyReactor(ObservableModel())

        XCTAssertEqual(model.counter, 9)

        let expectation = XCTestExpectation()
        Task {
            await model.send(action: .resetToZero)
            XCTAssertEqual(model.counter, 0, "Reset to zero failed")
            expectation.fulfill()
        }

        XCTAssertEqual(model.counter, 9, "State mutated immediately")

        await fulfillment(of: [expectation], timeout: 3)

        XCTAssertEqual(model.counter, 0, "State did not mutate properly")
    }

//    @MainActor func testLegacyModel() {
//        let model = AnyReactor(LegacyModel())
//
//        let expectation = XCTestExpectation(description: "Change notification was sent")
//
//        let cancellable = model.objectWillChange.sink {
//            expectation.fulfill()
//        }
//
//        model.send(action: .addOne)
//
//        XCTAssertEqual(model.counter, 10)
//        wait(for: [expectation], timeout: 3)
//        withExtendedLifetime(cancellable, {})
//    }

    @MainActor func testMultipleRuns() {
        let model = AnyReactor(ObservableModel())
        let expectation = XCTestExpectation(description: "5 concurrent runs finished at the same time")
        XCTAssertEqual(model.counter, 9)

        Task {
            await model.send(action: .multipleRuns) // 5 concurrent tasks for 1s
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 2)
        XCTAssertEqual(model.counter, 14)
    }

    @MainActor func testHundredRunsInForLoop() {
        let model = AnyReactor(ObservableModel())
        let expectation = XCTestExpectation(description: "100 concurrent runs finished at the same time")
        XCTAssertEqual(model.counter, 9)

        Task {
            await model.send(action: .hundredRuns) // 100 concurrent tasks for 1s
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.5)
        XCTAssertEqual(model.counter, 109)
    }

    /// Test 200 tasks running under one event, but added while the first ones were running, as mutations
    @MainActor func testTwiceHundredRuns() {
        let model = AnyReactor(ObservableModel())
        let expectation = XCTestExpectation(description: "100+100 concurrent runs finished at the same time")
        XCTAssertEqual(model.counter, 9)

        Task {
            await model.send(action: .twiceHundredRuns) // 100 + 100 more concurrent tasks for 1s
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.5)
        XCTAssertEqual(model.counter, 209)
    }

    @MainActor func testDebounce() async {
        let model = AnyReactor(ObservableModel())

        XCTAssertEqual(model.counter, 9)

        for _ in 0..<10 {
            await model.send(action: .debounceTest) // send event 10x in a second
            try? await Task.sleep(for: .milliseconds(100))
        }

        XCTAssertEqual(model.counter, 9) // event should be waiting in debouncer

        try? await Task.sleep(for: .seconds(1))

        XCTAssertEqual(model.counter, 10) // event should be debounced by now
    }

    @MainActor func testBinding() {
        let model = AnyReactor(ObservableModel())

        XCTAssertEqual(model.counter, 9)

        let binding = model.bind(\.counter, action: { .setCounter($0) })

        XCTAssertEqual(model.counter, 9)
        XCTAssertEqual(model.counter, binding.wrappedValue)
        binding.wrappedValue += 12
        XCTAssertEqual(model.counter, 21)
        XCTAssertEqual(binding.wrappedValue, 21)
        XCTAssertEqual(model.counter, binding.wrappedValue)
    }

}
