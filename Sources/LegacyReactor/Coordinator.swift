//
//  Coordinator.swift
//  GoodReactor
//
//  Created by Matúš Mištrik on 22/01/2025.
//

import Combine
import UIKit

@MainActor public protocol Coordinator: NSObject, AnyObject {

    ///`Set` of `AnyCancellable` objects used to keep track of any cancellables created while using `Combine`.
    var cancellables: Set<AnyCancellable> { get }

    ///Used to establish the coordinator hierarchy.
    var parentCoordinator: Coordinator? { get set }

    ///Pointer to all Coordinator objects, that uses this Coordinator as `parentCoordinator`.
    var children: NSPointerArray { get }

    ///Coordinator's root `UIViewController`
    var rootViewController: UIViewController? { get set }

}

extension Coordinator {

    ///Coordinator's root `UINavigationViewController`
    public var rootNavigationController: UINavigationController? {
        return rootViewController as? UINavigationController
    }

    /// Search for the first matching coordinator in hierarchy
    /// Need to setup parent coordinator to establish the coordinator hierarchy
    public func firstCoordinatorOfType<T>(type: T.Type) -> T? {
        if let thisCoordinator = self as? T {
            return thisCoordinator
        } else if let parentCoordinator = parentCoordinator {
            return parentCoordinator.firstCoordinatorOfType(type: T.self)
        }
        return nil
    }

    /// Search for the last matching coordinator in hierarchy
    /// Need to setup parent coordinator to establish the coordinator hierarchy
    public func lastCoordinatorOfType<T>(type: T.Type) -> T? {
        if let parentCoordinator = parentCoordinator,
           let lastResult = parentCoordinator.lastCoordinatorOfType(type: T.self) {
            return lastResult
        } else {
            return self as? T
        }
    }

    /// Recursively searches through all children of this coordinator and resets
    /// their children and parent references to `nil`.
    public func resetChildReferences() {
        while let child = children.popLast() as? Coordinator {
            child.resetChildReferences()
            child.parentCoordinator = nil
        }
    }

    /// Returns the most embedded coordinator in coordinator hierarchy with a specified type.
    /// Searches through all branches of coordinators and returns the last match. Result might
    /// not necessarilly be the most embedded coordinator with respecting type.
    /// - Parameter type: Type of child coordinator to find
    /// - Returns: Child coordinator of a specified type
    public func lastChildOfType<T>(type: T.Type) -> T? {
        guard let children = children.copy() as? NSPointerArray else { return self as? T }

        while let child = children.popLast() as? Coordinator {
            if let lastResult = child.lastChildOfType(type: T.self)  {
                return lastResult
            }
        }
        return self as? T
    }

    /// Returns the most embedded coordinator in the current branch of hierarchy. Does not check
    /// other branches and thus does not return the most embedded coordinator globally.
    /// This function does not search for a specific type of child coordinator unlike
    /// `lastChildOfType(type:)`.
    /// - Returns: Most embedded coordinator in current branch of hierarchy
    public func lastChild() -> Coordinator {
        guard let children = children.copy() as? NSPointerArray else { return self }

        while let child = children.popLast() as? Coordinator {
            return child.lastChild()
        }

        return self
    }

}
