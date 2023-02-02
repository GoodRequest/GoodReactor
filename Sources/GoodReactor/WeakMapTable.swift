//
//  WeakMapTable.swift
//
//  Created by Dominik Pethö on 9/3/20.
//  Copyright © 2020 GoodRequest. All rights reserved.
//

import Foundation

// MARK: - WeakMapTable
/// https://github.com/ReactorKit/WeakMapTable

/// The WeakMapTable class is a dictionary that uses weak references as its keys. It provides a way to associate values with keys, where the keys are objects.
/// The values are stored as long as the key objects are alive, and they are automatically removed when the key objects are deallocated.
final public class WeakMapTable<Key, Value> where Key: AnyObject {

    private var dictionary: [Weak<Key>: Value] = [:]
    private let lock = NSRecursiveLock()

    // MARK: Initializing

    /// Creates a new instance of WeakMapTable
    public init() {}

    // MARK: Getting and Setting Values

    /// Returns the value associated with the given key.
    /// This method locks the underlying dictionary to ensure thread safety,
    /// and installs a dealloc hook for the given key if it does not exist yet.
    ///
    /// - Parameter key: The key for which to return the associated value.
    /// - Returns: The value associated with the given key, or `nil` if no value is associated with the key.
    public func value(forKey key: Key) -> Value? {
        let weakKey = Weak(key)

        self.lock.lock()
        defer {
            self.lock.unlock()
            self.installDeallocHook(to: key)
        }

        return self.unsafeValue(forKey: weakKey)
    }

    /// Retrieves the value associated with the given key. If the key is not present, returns the default value passed in.
    /// - Parameters:
    ///   - key: The key for which to retrieve the associated value.
    ///   - default: A closure that provides a default value if the key is not present.
    /// - Returns: The value associated with the given key or the default value if the key is not present.
    public func value(forKey key: Key, default: @autoclosure () -> Value) -> Value {
        let weakKey = Weak(key)

        self.lock.lock()
        defer {
            self.lock.unlock()
            self.installDeallocHook(to: key)
        }

        if let value = self.unsafeValue(forKey: weakKey) {
            return value
        }

        let defaultValue = `default`()
        self.unsafeSetValue(defaultValue, forKey: weakKey)
        return defaultValue
    }

    // swiftlint:disable force_cast

    /// Retrieves the value associated with the given key, cast to the desired type T.
    /// - Parameters:
    ///   - key: The key whose associated value is to be retrieved
    ///   - default: A closure that returns the default value to be returned if the key is not found.
    /// - Returns: The value associated with key, cast to type T, or the default value if the key is not found.
    public func forceCastedValue<T>(forKey key: Key, default: @autoclosure () -> T) -> T {
        return self.value(forKey: key, default: `default`() as! Value) as! T
    }

    /// This method is used to set the value for a given key in the dictionary.
    /// - Parameters:
    ///   - value: The value to be stored.
    ///   - key: The key associated with the value.
    public func setValue(_ value: Value?, forKey key: Key) {
        let weakKey = Weak(key)

        self.lock.lock()
        defer {
            self.lock.unlock()
            if value != nil {
                self.installDeallocHook(to: key)
            }
        }

        if let value = value {
            self.dictionary[weakKey] = value
        } else {
            self.dictionary.removeValue(forKey: weakKey)
        }
    }

    // MARK: Getting and Setting Values without Locking

    /// Returns the value stored in the dictionary for the given key.
    /// This function is called unsafe because it does not provide thread-safety.
    /// - Parameter key: The key of the value stored in the dictonary
    /// - Returns: The value stored in dictonary
    private func unsafeValue(forKey key: Weak<Key>) -> Value? {
        return self.dictionary[key]
    }

    /// This function sets the value for the given key key in the dictionary. If value is non-nil, it is added to the dictionary, otherwise the value is removed from the dictionary.
    ///  This function is called unsafe because it does not provide thread-safety.
    /// - Parameters:
    ///   - value: The value to be set.
    ///   - key: The key associated with the value.
    private func unsafeSetValue(_ value: Value?, forKey key: Weak<Key>) {
        if let value = value {
            self.dictionary[key] = value
        } else {
            self.dictionary.removeValue(forKey: key)
        }
    }

    // MARK: Dealloc Hook

    private var deallocHookKey: Void?

    /// Adds a hook to an object's deallocation, so that the hook can clean up any resources associated with that object.
    /// - Parameter key: The key of the object to install the hook to.
    private func installDeallocHook(to key: Key) {
        let isInstalled = (objc_getAssociatedObject(key, &deallocHookKey) != nil)
        guard !isInstalled else { return }

        let weakKey = Weak(key)
        let hook = DeallocHook(handler: { [weak self] in
            self?.lock.lock()
            self?.dictionary.removeValue(forKey: weakKey)
            self?.lock.unlock()
        })
        objc_setAssociatedObject(key, &deallocHookKey, hook, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}

/// This class is used in the WeakMapTable class as a key in a dictionary to store values, where the keys are weak references to objects of type T.
/// This allows the values in the dictionary to be automatically removed when the objects they are associated with are deallocated.
private final class Weak<T>: Hashable where T: AnyObject {

    ///A hash value that is derived from the object's ObjectIdentifier.
    private let objectHashValue: Int
    /// A weak reference to an object of type T.
    weak var object: T?

    /// Initialization of class Weak
    /// - Parameter object: the object to be stored as a weak reference
    init(_ object: T) {
        self.objectHashValue = ObjectIdentifier(object).hashValue
        self.object = object
    }

    /// Combines the objectHashValue into the Hasher instance provided as an argument.
    /// - Parameter hasher: Hasher instance to hash
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.objectHashValue)
    }

    static func == (lhs: Weak<T>, rhs: Weak<T>) -> Bool {
        return lhs.objectHashValue == rhs.objectHashValue
    }
}

// MARK: - DeallocHook

/// DeallocHook is a private class that allows you to run a closure when its object is deallocated. It is used in WeakMapTable to handle deallocation of the keys in the table.
private final class DeallocHook {

    /// A closure that will be called when the object is deallocated.
    private let handler: () -> Void

    ///DeallocHook is initialized with a closure that is to be called when the object is deallocated. The closure is stored in the handler property.
    init(handler: @escaping () -> Void) {
        self.handler = handler
    }

    /// Call the handler closure when DeallocHook is deallocated
    deinit {
        self.handler()
    }
}
