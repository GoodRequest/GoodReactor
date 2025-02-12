//
//  HomeCoordinator.swift
//  GoodReactor-Sample
//
//  Created by GoodRequest on 08/02/2023.
//

import SwiftUI
import LegacyReactor

enum HomeStep {

    case goToAbout

}

class HomeCoordinator: GoodCoordinator<HomeStep> {

    override func start() -> UIViewController? {
        super.start()

        let homeViewModel = HomeViewModel(coordinator: self)
        let homeViewController = HomeViewController(viewModel: homeViewModel)

        let navigationController = UINavigationController(rootViewController: homeViewController)
        rootViewController = navigationController

        return rootViewController
    }

    override func navigate(to step: HomeStep) -> StepAction {
        switch step {
        case .goToAbout:
            let aboutViewController = AboutCoordinator(
                parentCoordinator: self
            ).start()

            return .push(aboutViewController)
        }
    }

}
