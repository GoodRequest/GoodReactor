//
//  AppDelegate.swift
//  GoodReactor-Sample
//
//  Created by GoodRequest on 08/02/2023.
//

import UIKit
import GoodReactor

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        window = UIWindow()

        UINavigationBar.configureAppearance()
        
        AppCoordinator(window: window).start()
        
        ReactorConfiguration.logger = SampleLogger()

        return true
    }

}

struct SampleLogger: ReactorLogger {
    
    func logReactorEvent(_ message: Any, level: LogLevel, fileName: String, lineNumber: Int) {
        print("[\(level)] \(message) (\(fileName):\(lineNumber))")
    }
    
}
