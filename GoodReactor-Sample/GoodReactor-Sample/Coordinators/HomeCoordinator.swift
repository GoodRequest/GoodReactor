//
//  HomeCoordinator.swift
//  GoodReactor-Sample
//
//  Created by GoodRequest on 08/02/2023.
//

import SwiftUI

enum HomeStep {

    case goToAbout

}

class HomeCoordinator: Coordinator<AppStep> {

    init() {
        super.init(rootViewController: UINavigationController())
    }

    override func start() -> UIViewController? {
        super.start()

        let homeViewModel = HomeViewModel(coordinator: self)
        let homeViewController = HomeViewController(viewModel: homeViewModel)

        navigationController?.viewControllers = [homeViewController]

        return rootViewController
    }

    override func navigate(to stepper: AppStep) -> StepAction {
        switch stepper {
        case .home(let homeStep):
            return navigate(to: homeStep)

        default:
            return .none
        }
    }

    func navigate(to step: HomeStep) -> StepAction {
        switch step {
        case .goToAbout:
            let aboutViewController = AboutCoordinator(
                rootViewController: rootViewController,
                parentCoordinator: self
            ).start()

            return .push(aboutViewController)
        }
    }

}
