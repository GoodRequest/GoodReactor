//
//  MemoryTests.swift
//  GoodReactor
//
//  Created by Andrej Jasso on 04/07/2026.
//
//  Covers https://github.com/GoodRequest/GoodReactor/issues/13

import XCTest
@testable import GoodReactor

@available(iOS 17.0, macOS 14.0, *)
final class MemoryTests: XCTestCase {

    /// A started reactor must deallocate once the last strong reference is dropped —
    /// external subscriptions must not keep it alive.
    @MainActor func testStartedReactorDeallocates() async {
        weak var weakModel: ObservableModel?

        do {
            let model = ObservableModel()
            model.start()
            await model.send(action: .addOne)
            XCTAssertEqual(model.counter, 10)
            weakModel = model
        }

        await waitUntil("Started reactor leaked") { weakModel == nil }
    }

    /// A type-erased reactor and its wrapped base must both deallocate.
    @MainActor func testAnyReactorDeallocates() async {
        weak var weakBase: ObservableModel?
        weak var weakModel: AnyReactor<ObservableModel.Action, ObservableModel.Destination, ObservableModel.State>?

        do {
            let base = ObservableModel()
            let model = AnyReactor(base)
            model.start()
            await model.send(action: .addOne)
            XCTAssertEqual(model.counter, 10)
            weakBase = base
            weakModel = model
        }

        await waitUntil("AnyReactor leaked") { weakModel == nil }
        await waitUntil("Wrapped base reactor leaked") { weakBase == nil }
    }

    /// When a started reactor deallocates, its subscription tasks must be
    /// cancelled and the subscribers disconnected from the publisher.
    @MainActor func testSubscriptionsAreReleasedAfterDealloc() async {
        var model: ObservableModel? = ObservableModel()
        let publisher = model!.manualEventPublisher

        model?.start()

        await waitUntil("Subscription was not created after start()") {
            await publisher.activeSubscriberCount == 1
        }

        model = nil

        await waitUntil("Subscriber was not released after reactor deallocated") {
            await publisher.activeSubscriberCount == 0
        }

        // sending to a publisher after its only subscriber is gone must be safe
        await publisher.send(1)
    }

    /// A reactor referenced by an in-flight event handler is kept alive only
    /// until the event finishes, then deallocates.
    @MainActor func testReactorDeallocatesAfterRunningEventFinishes() async {
        weak var weakModel: ObservableModel?

        do {
            let model = ObservableModel()
            weakModel = model
            Task { await model.send(action: .resetToZero) } // async handler runs for ~1 s
        }

        XCTAssertNotNil(weakModel, "Reactor deallocated while an event was still running")

        await waitUntil("Reactor leaked after running event finished") { weakModel == nil }
    }

}
