//
//  AppReactor.swift
//  GoodReactor-Sample
//
//  Created by Filip Šašala on 07/09/2024.
//

import GoodCoordinator
import NewReactor
import Observation
import SwiftUI

// TODO: Coordinator reactor macro for empty reactors
@Observable final class AppReactor: Reactor {

    typealias Event = NewReactor.Event<Action, Mutation, Destination>

    enum Action {

    }

    enum Mutation {

    }

    @Observable final class State {

    }

    @Navigable enum Destination: Tabs {

        static let initialDestination = Self.loggedOut

        case loggedOut
        case loggedIn

    }

    func makeInitialState() -> State {
        return State()
    }

    func reduce(state: inout State, event: Event) {
        
    }

}
