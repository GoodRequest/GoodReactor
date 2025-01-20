//
//  PublisherTests.swift
//  GoodReactor
//
//  Created by Filip Šašala on 28/08/2024.
//

import XCTest
@testable import GoodReactor

final class PublisherTests: XCTestCase {

    func testSubscriptions() async {
        let publisher = PassthroughPublisher<Int>()
        let subscriber = Subscriber<Int>()

        await subscriber.subscribe(to: publisher)

        let subscribers = await publisher.subscribers
        let x = subscribers.object(at: 0) === subscriber
        XCTAssert(x)
    }

    func testSendValue() async {
        let publisher = PassthroughPublisher<Int>()
        let subscriber = Subscriber<Int>()

        await subscriber.subscribe(to: publisher)

        let valueReceived = XCTestExpectation(description: "Value received - 10")
        Task {
            let element = await subscriber.next()
            if element == 10 {
                valueReceived.fulfill()
            } else {
                XCTFail("Did not receive expected value")
            }
        }

        await publisher.send(10)
        await fulfillment(of: [valueReceived], timeout: 3)
    }

    func testSequence() async {
        let publisher = PassthroughPublisher<Int>()
        let subscriber = Subscriber<Int>()

        await subscriber.subscribe(to: publisher)

        Task {
            for i in stride(from: 0, to: 100, by: 2) {
                await publisher.send(i)
            }
        }
        Task {
            for i in stride(from: 1, to: 100, by: 2) {
                await publisher.send(i)
            }
        }

        let expectation = XCTestExpectation(description: "All sent values received in order")
        expectation.assertForOverFulfill = true
        expectation.expectedFulfillmentCount = 100

        Task {
            for try await _ in subscriber {
                expectation.fulfill()
            }
        }

        await fulfillment(of: [expectation], timeout: 3)
    }

    func testMultipleSubscribers() async throws {
        let publisher = PassthroughPublisher<Int>()
        let subscriber1 = Subscriber<Int>()
        let subscriber2 = Subscriber<Int>()

        await subscriber1.subscribe(to: publisher)
        await subscriber2.subscribe(to: publisher)

        Task {
            for i in 0..<10 {
                await publisher.send(i)
            }
            await publisher.finish()
        }

        let expectation = XCTestExpectation(description: "Both subscribers received the same max value")
        expectation.expectedFulfillmentCount = 2
        Task {
            let max1 = await subscriber1.max()
            XCTAssertEqual(max1, 9)
            expectation.fulfill()
        }
        Task {
            let max2 = await subscriber2.max()
            XCTAssertEqual(max2, 9)
            expectation.fulfill()
        }

        await fulfillment(of: [expectation], timeout: 3)
    }

    @Broadcast var publishedWrapperCounter = 9

    func testPublishedWrapper() async {
        let subscriber = Subscriber<Int>()
        await subscriber.subscribe(to: $publishedWrapperCounter)

        let expectation = XCTestExpectation(description: "Received new value when a Published/Broadcast variable is set")

        Task {
            let result = await subscriber.next()
            XCTAssertEqual(result, 100)
            expectation.fulfill()
        }

        self.publishedWrapperCounter = 100

        await fulfillment(of: [expectation])
    }

}

// Only for testing purposes
extension NSPointerArray: @retroactive @unchecked Sendable {}
