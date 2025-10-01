//
//  Event.swift
//  GoodReactor
//
//  Created by Filip Šašala on 27/08/2024.
//

// MARK: - Event

public final class Event<A, M, D>: Sendable where A: Sendable, M: Sendable, D: Sendable {

    public enum Kind: Sendable {
        case action(A)
        case mutation(M)
        case destination(D?)
    }

    internal let id: EventIdentifier
    public let kind: Event.Kind

    internal init(kind: Event.Kind) {
        self.id = EventIdentifier()
        self.kind = kind
    }

    convenience private init(action: A) {
        self.init(kind: .action(action))
    }

    convenience private init(mutation: M) {
        self.init(kind: .mutation(mutation))
    }

    convenience public init(destination: D?) {
        self.init(kind: .destination(destination))
    }

}

// MARK: - Un-erase mutation

internal extension Event where M == AnyMutation {

    func castMutation<ConcreteMutation>(_ transform: (M) -> ConcreteMutation) -> Event<A, ConcreteMutation, D> {
        switch kind {
        case .action(let action):
            return Event<A, ConcreteMutation, D>(action: action)

        case .mutation(let mutation):
            return Event<A, ConcreteMutation, D>(mutation: transform(mutation))

        case .destination(let destination):
            return Event<A, ConcreteMutation, D>(destination: destination)
        }
    }

}

// MARK: - Event identifier

internal final class EventIdentifier: Identifier, Sendable {}
