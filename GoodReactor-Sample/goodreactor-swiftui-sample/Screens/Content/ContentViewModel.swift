//
//  ContentViewModel.swift
//  GoodReactor-Sample
//
//  Created by Filip Šašala on 07/09/2024.
//

import GoodCoordinator
import NewReactor
import Observation
import SwiftUI

@Observable final class ContentViewModel: Reactor {

    typealias Event = NewReactor.Event<Action, Mutation, Destination>

    enum Action {

        case fetchData
        case setText(String)

    }

    enum Mutation {

        case didFetchData

    }

    @Observable final class State {

        var isLoading = false
        var counter: Int = 10
        var text = "Hello, world!"

    }

    @Navigable enum Destination {

        case detail(Int)

        case presentSheet
        case presentSheet2
        case pushScreen
        case errorAlert
        case confirmationDialog

    }

    func makeInitialState() -> State {
        return State()
    }

    func reduce(state: inout State, event: Event) {
        switch event.kind {
        case .action(.setText(let newText)):
            state.text = newText

        case .action(.fetchData):
            state.isLoading = true
            run(event) { await self.fetchData() }

        case .mutation(.didFetchData):
            print("data fetching done")

        case .destination:
            break
        }
    }

    func fetchData() async -> Mutation {
        return .didFetchData
    }

}
