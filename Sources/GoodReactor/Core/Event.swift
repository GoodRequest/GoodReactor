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

    private init(id: EventIdentifier, action: A) {
        self.id = id
        self.kind = .action(action)
    }

    private init(id: EventIdentifier, mutation: M) {
        self.id = id
        self.kind = .mutation(mutation)
    }

    private init(id: EventIdentifier, destination: D?) {
        self.id = id
        self.kind = .destination(destination)
    }

    // To be used from GoodCoordinator package
    convenience public init(destination: D?) {
        self.init(kind: .destination(destination))
    }

}

// MARK: - Un-erase mutation

internal extension Event where M == AnyMutation {

    func castMutation<ConcreteMutation>(_ transform: (M) -> ConcreteMutation) -> Event<A, ConcreteMutation, D> {
        switch kind {
        case .action(let action):
            return Event<A, ConcreteMutation, D>(id: id, action: action)

        case .mutation(let mutation):
            return Event<A, ConcreteMutation, D>(id: id, mutation: transform(mutation))

        case .destination(let destination):
            return Event<A, ConcreteMutation, D>(id: id, destination: destination)
        }
    }

}

// MARK: - Event identifier

internal final class EventIdentifier: Identifier, Sendable {}
