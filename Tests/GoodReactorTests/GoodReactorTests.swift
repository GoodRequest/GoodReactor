//
//  GoodReactorTests.swift
//  GoodReactor
//
//  Created by Filip Šašala on 23/08/2024.
//

import XCTest
@testable import GoodReactor

import Combine
import SwiftUI

@available(iOS 17.0, macOS 14.0, *)
final class GoodReactorTests: XCTestCase {

    @MainActor func testSendAction() {
        let model = ObservableModel()

        model.send(action: .addOne)

        XCTAssertEqual(model.initialState.counter, 9, "Initial state mutated")
        XCTAssertEqual(model.state.counter, 10, "Sending action failed")
    }

    @MainActor func testInitialState() {
        let model = ObservableModel()

        XCTAssertEqual(model.initialState.counter, 9, "Invalid initial state")
        XCTAssertEqual(model.counter, 9, "Invalid initial state")

        XCTAssertNotIdentical(model.state, model.initialState, "Initial state is NOT A COPY but a reference!")
        XCTAssertNotIdentical(model.object, model.initialState.object, "Current state has a reference to initial state with possible mutations!")
    }

    @MainActor func testActionMutation() async throws {
        let model = ObservableModel()

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

    @MainActor func testLegacyModel() {
        let model = LegacyModel()

        let expectation = XCTestExpectation(description: "Change notification was sent")

        let cancellable = model.objectWillChange.sink {
            expectation.fulfill()
        }

        model.send(action: .addOne)

        XCTAssertEqual(model.counter, 10)
        wait(for: [expectation], timeout: 3)
        withExtendedLifetime(cancellable, {})
    }

    @MainActor func testMultipleRuns() {
        let model = ObservableModel()
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
        let model = ObservableModel()
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
        let model = ObservableModel()
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
        let model = ObservableModel()

        XCTAssertEqual(model.counter, 9)

        for _ in 0..<10 {
            await model.send(action: .debounceTest) // all sends fall within the 500 ms debounce window
        }

        XCTAssertEqual(model.counter, 9) // event should be waiting in debouncer

        await waitUntil("Debounced event did not fire") { model.counter == 10 }

        // negative check: give any spurious extra debounce fires time to land
        try? await Task.sleep(for: .seconds(1))

        XCTAssertEqual(model.counter, 10, "Debounced event fired more than once")
    }

    @MainActor func testBinding() {
        let model = ObservableModel()

        XCTAssertEqual(model.counter, 9)

        let binding = model.bind(\.counter, action: { .setCounter($0) })

        XCTAssertEqual(binding.wrappedValue, 9)
        binding.wrappedValue += 12
        XCTAssertEqual(binding.wrappedValue, 21)
    }

    @MainActor func testReactorStartIdempontency() async {
        let model = ObservableModel()
        let publisher = model.manualEventPublisher

        XCTAssertEqual(model.manualEventsCount, 0)

        model.start()

        await waitUntil("Subscription was not created after start()") {
            await publisher.activeSubscriberCount == 1
        }

        let subscriptionCount = MapTables.subscriptions.value(forKey: model)?.count ?? 0
        XCTAssertGreaterThan(subscriptionCount, 0)

        model.start()
        model.start()
        model.start()

        // subscription tasks are registered synchronously in start(),
        // so duplicates would be visible immediately
        XCTAssertEqual(MapTables.subscriptions.value(forKey: model)?.count, subscriptionCount)

        await publisher.send(1)
        await waitUntil("Manual event was not delivered") { model.manualEventsCount == 1 }

        await publisher.send(1)
        await waitUntil("Manual event was not delivered") { model.manualEventsCount == 2 }

        let subscriberCount = await publisher.activeSubscriberCount
        XCTAssertEqual(subscriberCount, 1, "Duplicate subscriptions were created")
    }

}
