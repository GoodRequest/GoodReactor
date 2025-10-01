//
//  Mutation.swift
//  GoodReactor
//
//  Created by Filip Šašala on 01/10/2025.
//

public struct AnyMutation: Sendable {

    internal let `enum`: (Any & Sendable)

    internal init<E: Sendable>(_ `enum`: E) {
        self.enum = `enum`
    }

    internal func `as`<T>(_: T.Type) -> T? {
        `enum` as? T
    }

}
