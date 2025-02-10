//
//  SharedScope.swift
//  GoodReactor
//
//  Created by Filip Šašala on 13/02/2025.
//

import Foundation

// MARK: - Shared scope

public final class SharedScope: @unchecked Sendable {

    internal static let shared = SharedScope()
    internal static let keyStore = KeyStore()

    private init() {}

    private var scopeMapTable: WeakMapTable<AnyObject, Any> = .init()

    nonisolated public static func value<K: SharedScopeKey>(forKey scopeKey: K) -> K.Value {
        let value = shared.scopeMapTable.forceCastedValue(forKey: scopeKey.id, default: K.defaultValue)
        return value
    }

    nonisolated public static func setValue<K: SharedScopeKey>(forKey scopeKey: K, value: K.Value?) {
        if let value {
            shared.scopeMapTable.setValue(value, forKey: scopeKey.id)
        }
    }

}

// MARK: - Shared scope key

public protocol SharedScopeKey<Value>: ScopeKey {

    static var defaultValue: Value { get }

}

public extension SharedScopeKey {

    var id: any Identifier {
        return SharedScope.keyStore.key(named: String(describing: Self.self))
    }

}

