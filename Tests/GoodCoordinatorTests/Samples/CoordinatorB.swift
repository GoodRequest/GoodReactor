//
//  CoordinatorB.swift
//  GoodReactor
//
//  Created by Matúš Mištrik on 20/01/2025.
//

import UIKit
import LegacyReactor

enum CustomStepB { }

class CoordinatorB: GoodCoordinator<CustomStepB> {

    override func start() -> UIViewController {
        super.start()

        let controller = UIViewController()

        if rootViewController == nil {
            rootViewController = controller
        }

        return controller
    }

    override func navigate(to stepper: CustomStepB) -> StepAction {
        return .none
    }

}
