//
//  DetailViewModel.swift
//  GoodReactor-Sample
//
//  Created by Filip Šašala on 11/09/2024.
//

import GoodCoordinator
import GoodReactor
import Observation

@Observable final class DetailViewModel: Reactor {

    typealias Event = GoodReactor.Event<Action, Mutation, Destination>

    enum Action {

    }

    enum Mutation {

    }

    @Navigable enum Destination {

        case detail(Int)

    }

    @Observable final class State {

    }

    func makeInitialState() -> State {
        State()
    }

    func reduce(state: inout State, event: Event) {
        
    }

}
