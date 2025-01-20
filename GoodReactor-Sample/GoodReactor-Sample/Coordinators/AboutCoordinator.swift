//
//  AboutCoordinator.swift
//  GoodReactor-Sample
//
//  Created by GoodRequest on 08/02/2023.
//

import UIKit

enum AboutStep {}

class AboutCoordinator: BaseCoordinator<AppStep> {

    override func start() -> AboutViewController {
        super.start()

        let aboutViewModel = AboutViewModel(coordinator: self)
        let aboutViewController = AboutViewController(viewModel: aboutViewModel)

        if rootViewController == nil {
            rootViewController = aboutViewController
        }

        return aboutViewController
    }

    override func navigate(to stepper: AppStep) -> StepAction {
        switch stepper {
        case .safari(let url):
            return .safari(url)

        default:
            return .none
        }
    }

}
