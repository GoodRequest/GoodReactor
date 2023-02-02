//
//  AppCoordinator.swift
//  GoodReactor-Sample
//
//  Created by GoodRequest on 08/02/2023.
//

import UIKit

enum AppStep {

    case home(HomeStep)
    case safari(URL)

}

final class AppCoordinator: Coordinator<AppStep> {

    // MARK: - Constants

    private let window: UIWindow?

    // MARK: - Init

    init(window: UIWindow?) {
        self.window = window
    }

    @discardableResult
    override func start() -> UIViewController? {
        super.start()

        window?.rootViewController = HomeCoordinator().start()
        window?.makeKeyAndVisible()

        return window?.rootViewController
    }

}
