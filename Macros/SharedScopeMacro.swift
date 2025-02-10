//
//  SharedScopeMacro.swift
//  GoodReactor
//
//  Created by Filip Šašala on 13/02/2025.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxMacros

public struct SharedScopeMacro: PeerMacro, AccessorMacro {

    // MARK: - Peer macro

    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let varSyntax = declaration.as(VariableDeclSyntax.self) else {
            throw SharedScopeMacroError.notVariable
        }

        // Enforce Shared variables only in classes
        guard let enclosingClassDecl = context.lexicalContext.first?.as(ClassDeclSyntax.self) else {
            throw SharedScopeMacroError.noObservableClass
        }

        // Enforce Shared variables only in @Observable classes
        guard enclosingClassDecl.attributes.hasAttribute(named: "Observable") else {
            throw SharedScopeMacroError.noObservableClass
        }

        // Warn if @ObservationIgnored macro is missing
        guard varSyntax.attributes.hasAttribute(named: "ObservationIgnored") else {
            throw SharedScopeMacroError.doubleObservation
        }

        guard let identifier = varSyntax.bindings.first?.pattern.as(IdentifierPatternSyntax.self) else {
            throw SharedScopeMacroError.varNameInvalid
        }

        let varName = identifier.identifier.text

        guard let type = varSyntax.bindings.first?.typeAnnotation?.type.as(IdentifierTypeSyntax.self)?.description else {
            throw SharedScopeMacroError.missingType
        }

//        guard let initializer = varSyntax.bindings.first?.initializer?.value.description else {
//            throw SharedScopeMacroError.notInitialized
//        }

        guard let defaultValue = node.arguments?.as(LabeledExprListSyntax.self)?.first?.expression else {
            throw SharedScopeMacroError.notInitialized
        }

        let keySharedStructDecl = DeclSyntax("""
        private struct __Key_Shared_\(raw: varName): SharedScopeKey {
            static var defaultValue: \(raw: type) { \(raw: defaultValue) }
        }
        """)

        let keySharedVarDecl = DeclSyntax("""
        private let __key_shared_\(raw: varName) = __Key_Shared_\(raw: varName)()
        """)

        return [keySharedStructDecl, keySharedVarDecl]
    }

    // MARK: - Accessor macro

    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        guard let varSyntax = declaration.as(VariableDeclSyntax.self) else {
            throw SharedScopeMacroError.notVariable
        }

        guard let identifier = varSyntax.bindings.first?.pattern.as(IdentifierPatternSyntax.self) else {
            throw SharedScopeMacroError.varNameInvalid
        }

        let varName = identifier.identifier.text

        let getter = AccessorDeclSyntax("""
        get {
            _$observationRegistrar.access(self, keyPath: \\.\(raw: varName))
            return SharedScope.value(forKey: __key_shared_\(raw: varName))
        }
        """)

        let setter = AccessorDeclSyntax("""
        set {
            _$observationRegistrar.willSet(self, keyPath: \\.\(raw: varName))
            SharedScope.setValue(forKey: __key_shared_\(raw: varName), value: newValue)
            _$observationRegistrar.didSet(self, keyPath: \\.\(raw: varName))
        }
        """)

        return [getter, setter]
    }

}

// MARK: - Helpers

extension AttributeListSyntax {

    func hasAttribute(named attributeName: String) -> Bool {
        return self.contains(where: { attribute in
            attribute.as(AttributeSyntax.self)?.attributeName.as(IdentifierTypeSyntax.self)?.name.text == attributeName
        })
    }

}

// MARK: - Errors

enum SharedScopeMacroError: Error, CustomStringConvertible {

    case notVariable
    case varNameInvalid
    case missingType
    case notInitialized
    case noObservableClass
    case doubleObservation
    case other(String)

    var description: String {
        switch self {
        case .notVariable:
            return "Scope can only be applied to a variable"

        case .varNameInvalid:
            return "Variable identifier is missing or is not a valid identifier"

        case .missingType:
            return "You must exactly specify a type of the shared variable"

        case .notInitialized:
            return "Variable must be initialized or provide a default value"

        case .noObservableClass:
            return "Shared variable must be contained in an @Observable class"

        case .doubleObservation:
            return "Shared variable must opt out of automatic observation. Add @ObservationIgnored macro as the last macro on the variable"

        case .other(let description):
            return description
        }
    }

}
