//
//  ScopeKey.swift
//  GoodReactor
//
//  Created by Filip Šašala on 13/02/2025.
//

public protocol ScopeKey {

    associatedtype Value

    init()

    var id: any Identifier { get }
    static var defaultValue: Value { get }

}
