//
//  AppCoordinator.swift
//  GoodReactor-Sample
//
//  Created by GoodRequest on 08/02/2023.
//

import UIKit
import LegacyReactor

enum AppStep {

    case home(HomeStep)
    case safari(URL)

}

final class AppCoordinator: GoodCoordinator<AppStep> {

    // MARK: - Constants

    private let window: UIWindow?

    // MARK: - Init

    init(window: UIWindow?) {
        self.window = window
        
        super.init()
    }

    required init(rootViewController: UIViewController? = nil) {
        fatalError("init(rootViewController:parentCoordinator:) has not been implemented")
    }

    required init(parentCoordinator: Coordinator?) {
        fatalError("init(parentCoordinator:) has not been implemented")
    }

    @discardableResult
    override func start() -> UIViewController? {
        super.start()

        window?.rootViewController = HomeCoordinator().start()
        window?.makeKeyAndVisible()

        return window?.rootViewController
    }

}
