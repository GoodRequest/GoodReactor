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

// MARK: - Code location identifier

public final class CodeLocationIdentifier: Identifier {

    public let id: String

    public init(_ file: StaticString = #file, _ line: UInt = #line, _ column: UInt = #column) {
        self.id = "\(file):\(line):\(column)"
    }

}
