//
//  Event.swift
//  GoodReactor
//
//  Created by Filip Šašala on 27/08/2024.
//

public final class Event<A, M, D>: Sendable where A: Sendable, M: Sendable, D: Sendable {

    public enum Kind: Sendable {
        case action(A)
        case mutation(M)
        case destination(D)
    }

    internal let id: EventIdentifier
    public let kind: Event.Kind

    internal init(kind: Event.Kind) {
        self.id = EventIdentifier()
        self.kind = kind
    }

    convenience public init(destination: D) {
        self.init(kind: .destination(destination))
    }

}

internal final class EventIdentifier: Identifier, Sendable {}
