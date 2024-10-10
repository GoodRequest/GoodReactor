//
//  ProfileViewModel.swift
//  goodreactor-swiftui-sample
//
//  Created by Filip Šašala on 24/09/2024.
//

import Foundation
import GoodCoordinator
import GoodReactor
import Observation

@Observable final class ProfileViewModel: Reactor {

    typealias Event = GoodReactor.Event<Action, Mutation, Destination>

    enum Action {

    }

    enum Mutation {

    }

    @Observable final class State {

    }

    @Navigable enum Destination {

    }

    func makeInitialState() -> State {
        return State()
    }

    func reduce(state: inout State, event: Event) {

    }

}

