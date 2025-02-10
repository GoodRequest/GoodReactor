//
//  ScopeMacros.swift
//  GoodReactor
//
//  Created by Filip Šašala on 13/02/2025.
//

import Foundation

//@attached(extension, conformances: DestinationCaseNavigable)
//@attached(peer, names: arbitrary)
//public macro Navigable() = #externalMacro(module: "GoodCoordinatorMacros", type: "Navigable")
//
//@attached(member, names: named(__navigationPath))
//@attached(peer, names: named(__module_rootNavigationPath))
//public macro NavigationRoot() = #externalMacro(module: "GoodCoordinatorMacros", type: "NavigationRoot")

@attached(accessor)
@attached(peer, names: prefixed(__Key_Shared_), prefixed(__key_shared_))
public macro Shared<T>(default: T) = #externalMacro(module: "GoodReactorMacros", type: "SharedScopeMacro")
