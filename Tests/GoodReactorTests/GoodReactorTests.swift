//
//  GoodReactorTests.swift
//  GoodReactor
//
//  Created by Filip Šašala on 23/08/2024.
//

import XCTest
@testable import GoodReactor
import Combine

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
        XCTAssertEqual(model.state.counter, 9, "Invalid initial state")

        XCTAssertNotIdentical(model.state, model.initialState, "Initial state is NOT A COPY but a reference!")
        XCTAssertNotIdentical(model.state.object, model.initialState.object, "Current state has a reference to initial state with possible mutations!")
    }

    @MainActor func testActionMutation() async throws {
        let model = ObservableModel()

        XCTAssertEqual(model.state.counter, 9)

        let expectation = XCTestExpectation()
        Task {
            await model.send(action: .resetToZero)
            XCTAssertEqual(model.state.counter, 0, "Reset to zero failed")
            expectation.fulfill()
        }

        XCTAssertEqual(model.state.counter, 9, "State mutated immediately")

        await fulfillment(of: [expectation], timeout: 3)

        XCTAssertEqual(model.state.counter, 0, "State did not mutate properly")
    }

    @MainActor func testLegacyModel() {
        let model = LegacyModel()

        let expectation = XCTestExpectation(description: "Change notification was sent")

        let cancellable = model.objectWillChange.sink {
            expectation.fulfill()
        }

        model.send(action: .addOne)

        XCTAssertEqual(model.state.counter, 10)
        wait(for: [expectation], timeout: 3)
        withExtendedLifetime(cancellable, {})
    }

}
