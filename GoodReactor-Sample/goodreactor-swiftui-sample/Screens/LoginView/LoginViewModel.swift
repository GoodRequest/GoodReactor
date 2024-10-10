//
//  LoginViewModel.swift
//  goodreactor-swiftui-sample
//
//  Created by Filip Šašala on 26/09/2024.
//

import Foundation
import GoodCoordinator
import GoodReactor
import Observation

@Observable final class LoginViewModel: Reactor {

    typealias Event = GoodReactor.Event<Action, Mutation, Destination>

    enum Action {

        case sendLoginRequest

    }

    enum Mutation {

    }

    @Observable final class State {

    }

    @Navigable enum Destination: CaseIterable {

    }

    func makeInitialState() -> State {
        return State()
    }

    func reduce(state: inout State, event: Event) {
        switch event.kind {
        case .action(.sendLoginRequest):
            run(event) {
                // send request here (asynchronously)
                // process

                // route (on MainActor)
                await #router.route(AppReactor.self, .loggedIn)

                // no mutation
                return nil
            }
        }
    }

}

