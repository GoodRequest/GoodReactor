//
//  TabBarViewModel.swift
//  goodreactor-swiftui-sample
//
//  Created by Filip Šašala on 26/09/2024.
//

import Foundation
import GoodCoordinator
import NewReactor
import Observation

@Observable final class HomeViewModel: Reactor {

    typealias Event = NewReactor.Event<Action, Mutation, Destination>

    enum Action {

    }

    enum Mutation {

    }

    @Observable final class State {

    }

    @Navigable enum Destination: Tabs {

        static let initialDestination = Self.home

        case home
        case profile

    }

    func makeInitialState() -> State {
        return State()
    }

    func reduce(state: inout State, event: Event) {

    }

}
