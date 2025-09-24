//
//  Stub.swift
//  GoodReactor
//
//  Created by Filip Šašala on 24/09/2025.
//

import Observation

@available(iOS 17.0, macOS 14.0, *)
@Observable public final class Stub<R: Reactor>: Reactor {

    public typealias Event = R.Event
    public typealias Action = R.Action
    public typealias Mutation = R.Mutation
    public typealias Destination = R.Destination
    public typealias State = R.State

    public var destination: R.Destination?
    public var destinations: R.Destination.Type?

    private let supplier: () -> (R.State)
    private let reducer: ((inout R.State, Event) -> ())?

    public func makeInitialState() -> R.State {
        supplier()
    }

    public func reduce(state: inout R.State, event: Event) {
        reducer?(&state, event)
    }

    public init(
        supplier: @escaping (() -> (R.State)),
        reducer: ((inout R.State, Event) -> ())? = nil
    ) {
        self.supplier = supplier
        self.reducer = reducer
    }

}
