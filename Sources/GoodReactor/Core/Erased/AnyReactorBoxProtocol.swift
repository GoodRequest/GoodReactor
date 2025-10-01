//
//  AnyReactorBoxProtocol.swift
//  GoodReactor
//
//  Created by Filip Šašala on 01/10/2025.
//

/// Box protocol marking the interface of type-erased reactor with no concrete `Mutation` type
@MainActor internal protocol AnyReactorBoxProtocol<Action, Destination, State>: AnyObject {

    associatedtype Action: Sendable
    associatedtype Destination: Sendable
    associatedtype State

    var state: State { get set }
    var destination: Destination? { get }

    func makeInitialState() -> State
    func transform()
    func send(action: Action)
    func send(action: Action) async
    func send(destination: Destination?)

    func reduceAny(state: inout State, event: Event<Action, AnyMutation, Destination>)

}
