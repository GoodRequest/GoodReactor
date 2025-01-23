//
//  ExternalTimer.swift
//  GoodReactor
//
//  Created by Filip Šašala on 30/08/2024.
//

import Foundation
import GoodReactor

// MARK: - Example - external dependency

/// Sample timer that publishes current time for 100 seconds
final class ExternalTimer: @unchecked Sendable {

    @MainActor static let shared = ExternalTimer()
    let timePublisher = GoodReactor.PassthroughPublisher<Int>()

    init() {
        Task {
            for _ in 0..<100 {
                try await Task.sleep(nanoseconds: UInt64(1e9))
                await self.timePublisher.send(Int(Date().timeIntervalSince1970))
            }
        }
    }

}
