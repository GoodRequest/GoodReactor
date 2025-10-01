//
//  AnyReactorBox.swift
//  GoodReactor
//
//  Created by Filip Šašala on 01/10/2025.
//

/// `AnyReactor` box which forwards calls to concrete implementation of `base` Reactor.
@MainActor internal final class AnyReactorBox<Base: Reactor>: AnyReactorBoxProtocol {

    typealias Action = Base.Action
    typealias Destination = Base.Destination
    typealias State = Base.State

    private let base: Base

    init(_ base: Base) {
        self.base = base
    }

    var state: Base.State {
        get { base.state }
        set { base.state = newValue }
    }

    var destination: Base.Destination? {
        get { base.destination }
    }

    func makeInitialState() -> Base.State {
        base.makeInitialState()
    }

    func transform() {
        base.transform()
    }

    func send(action: Base.Action) {
        base.send(action: action)
    }

    func send(action: Base.Action) async {
        await base.send(action: action)
    }

    func send(destination: Base.Destination?) {
        base.send(destination: destination)
    }

    func reduceAny(state: inout Base.State, event: Event<Base.Action, AnyMutation, Base.Destination>) {
        let concreteEvent = event.castMutation { anyMutation in
            guard let concreteMutation = anyMutation.as(Base.Mutation.self) else {
                fatalError("Unexpected mutation type: \(type(of: anyMutation)), expected \(Base.Mutation.self)")
            }
            return concreteMutation
        }

        base.reduce(state: &state, event: concreteEvent)
    }

}
