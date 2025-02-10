//
//  MacroCollection.swift
//  GoodReactor
//
//  Created by Filip Šašala on 13/02/2025.
//

import Foundation
import SwiftCompilerPlugin
@_spi(ExperimentalLanguageFeature) import SwiftSyntaxMacros

@main struct MacroCollection: CompilerPlugin {

    let providingMacros: [Macro.Type] = [
        SharedScopeMacro.self
    ]

}
