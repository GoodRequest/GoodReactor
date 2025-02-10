//
//  KeyStore.swift
//  GoodReactor
//
//  Created by Filip Šašala on 13/02/2025.
//

import Foundation

// MARK: - Scope KeyStore

internal final class KeyStore: @unchecked Sendable {

    internal final class Key: Identifier {
        let name: String

        init(name: String) {
            self.name = name
        }
    }

    private var keys: [String: KeyStore.Key] = [:]
    private let lock = NSLock()

    internal func key(named name: String) -> Key {
        lock.lock()
        defer { lock.unlock() }

        if let existingKey = keys[name] {
            return existingKey
        }

        let newKey = Key(name: name)
        keys[name] = newKey
        return newKey
    }

    internal func removeKey(named name: String) {
        lock.lock()
        keys.removeValue(forKey: name)
        lock.unlock()
    }

}

// MARK: - Helper function

public func address(of object: AnyObject) -> String {
    String(describing: Unmanaged.passUnretained(object).toOpaque())
}
