//
//  goodreactor_swiftui_sampleApp.swift
//  goodreactor-swiftui-sample
//
//  Created by Filip Šašala on 07/09/2024.
//

import GoodCoordinator
import GoodReactor
import SwiftUI

@main struct goodreactor_swiftui_sampleApp: App {

    var body: some Scene {
        WindowGroup {
            MainWindow()
        }
    }

}

@NavigationRoot struct MainWindow: View {

    @ViewModel private var mainWindowModel = AppReactor()

    var body: some View {
        switch mainWindowModel.destination {
        case .loggedIn:
            HomeView()

        case .loggedOut:
            LoginView()

        case .none:
            EmptyView()
        }
    }

}
