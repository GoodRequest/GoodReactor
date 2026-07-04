//
//  TestWaiting.swift
//  GoodReactor
//
//  Created by Andrej Jasso on 04/07/2026.
//

import XCTest
@testable import GoodReactor

extension XCTestCase {

    /// Polls `condition` until it evaluates to `true` or `timeout` elapses.
    ///
    /// Use instead of fixed `Task.sleep` delays: passes as soon as the condition
    /// holds (fast on fast machines) and only fails after the full timeout
    /// (robust on slow CI runners).
    @MainActor func waitUntil(
        timeout: Duration = .seconds(5),
        _ message: @autoclosure () -> String = "Condition not met within timeout",
        condition: @MainActor () async -> Bool,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async {
        let clock = ContinuousClock()
        let deadline = clock.now.advanced(by: timeout)

        while clock.now < deadline {
            if await condition() { return }
            try? await Task.sleep(for: .milliseconds(10))
        }

        if await condition() { return }
        XCTFail(message(), file: file, line: line)
    }

}

extension PassthroughPublisher {

    /// Number of live subscribers currently connected to this publisher.
    /// Test-only introspection used to deterministically wait for
    /// asynchronous subscription setup and teardown.
    var activeSubscriberCount: Int {
        subscribers.removeNils()
        return subscribers.count
    }

}
