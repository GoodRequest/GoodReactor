//
//  HomeViewModel.swift
//  GoodReactor-Sample
//
//  Created by GoodRequest on 08/02/2023.
//

import Combine
import LegacyReactor

final class HomeViewModel: GoodReactor {


    // MARK: - Enums

    enum CounterMode {

        case increase
        case decrease

    }

    enum Action {

        case goToAbout
        case updateCounterValue(CounterMode)

    }

    enum Mutation {

        case counterValueUpdated(Int)

    }

    // MARK: - Structs

    struct State {

        var counterValue: Int

    }

    // MARK: - Constants

    internal let initialState: State
    internal let coordinator: GoodCoordinator<HomeStep>

    // MARK: - Initialization

    init(coordinator: GoodCoordinator<HomeStep>) {
        self.coordinator = coordinator
        initialState = State(counterValue: 0)
    }

}

// MARK: - Coordinator

extension HomeViewModel {

    func navigate(action: Action) -> HomeStep? {
        switch action {
        case .goToAbout:
            return .goToAbout

        default:
            return .none
        }
    }

}

// MARK: - Reactive

extension HomeViewModel {

    func mutate(action: Action) -> AnyPublisher<Mutation, Never> {
        switch action {
        case .updateCounterValue(let mode):
            return updateCounter(mode: mode)

        case .goToAbout:
            return Empty().eraseToAnyPublisher()
        }
    }

    func reduce(state: State, mutation: Mutation) -> State {
        var state = state

        switch mutation {
        case .counterValueUpdated(let newValue):
            state.counterValue = newValue
        }

        return state
    }

}

// MARK: - Private

private extension HomeViewModel {

    func updateCounter(mode: CounterMode) -> AnyPublisher<Mutation,Never> {
        var actualValue = currentState.counterValue

        switch mode {
        case .increase:
            actualValue += 1

        case .decrease:
            actualValue -= 1
        }

        return Just(.counterValueUpdated(actualValue)).eraseToAnyPublisher()
    }

}
