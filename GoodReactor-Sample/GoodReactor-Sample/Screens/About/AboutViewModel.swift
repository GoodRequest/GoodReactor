// 
//  AboutViewModel.swift
//  GoodReactor-Sample
//
//  Created by GoodRequest on 08/02/2023.
//

import Combine
import Foundation
import LegacyReactor

final class AboutViewModel: GoodReactor {

    // MARK: - Enums

    enum Action {

        case goToDocumentation
        case goToAboutUs

    }

    enum Mutation {}

    struct State {}

    // MARK: - Constants

    internal let initialState: State
    internal let coordinator: GoodCoordinator<AboutStep>


    // MARK: - Initialization

    init(coordinator: GoodCoordinator<AboutStep>) {
        self.coordinator = coordinator

        initialState = State()
    }

}

// MARK: - Coordinator

extension AboutViewModel {

    func navigate(action: Action) -> AboutStep? {
        switch action {
        case .goToDocumentation:
            guard let url = URL(string: Constants.Links.documentation) else { return .none }

            return .browser(url)

        case .goToAboutUs:
            guard let url = URL(string: Constants.Links.aboutUs) else { return .none }

            return .browser(url)
        }
    }

}

// MARK: - Reactive

extension AboutViewModel {

    func mutate(action: Action) -> AnyPublisher<Mutation, Never> {
        return Empty().eraseToAnyPublisher()

    }

    func reduce(state: State, mutation: Mutation) -> State {
        return state
    }

}
