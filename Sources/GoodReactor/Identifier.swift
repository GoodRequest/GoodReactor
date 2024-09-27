//
//  Identifier.swift
//  GoodReactor
//
//  Created by Filip Šašala on 27/08/2024.
//

// MARK: - Identifier

public protocol Identifier: AnyObject, Identifiable, Equatable, Hashable {}

public extension Identifier {

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

}
