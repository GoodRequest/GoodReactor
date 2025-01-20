//
//  AboutCoordinator.swift
//  GoodReactor-Sample
//
//  Created by GoodRequest on 08/02/2023.
//

import UIKit
import LegacyReactor

enum AboutStep {

    case browser(URL)

}

class AboutCoordinator: GoodCoordinator<AboutStep> {

    override func start() -> UIViewController {
        super.start()

        let aboutViewModel = AboutViewModel(coordinator: self)
        let aboutViewController = AboutViewController(viewModel: aboutViewModel)

        if rootViewController == nil {
            rootViewController = aboutViewController
        }

        return aboutViewController
    }

    override func navigate(to step: AboutStep) -> StepAction {
        print("DEBUG: - hello")
        switch step {
        case .browser(let url):
            return .safari(url)
        }
    }

}
