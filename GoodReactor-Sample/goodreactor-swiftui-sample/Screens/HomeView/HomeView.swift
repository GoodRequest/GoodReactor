//
//  TabBarView.swift
//  goodreactor-swiftui-sample
//
//  Created by Filip Šašala on 26/09/2024.
//

import SwiftUI
import GoodReactor

struct HomeView: View {

    // MARK: - Wrappers

    @ViewModel private var model = HomeViewModel()

    // MARK: - View state

    // MARK: - Properties

    // MARK: - Initialization

    // MARK: - Computed properties

    // MARK: - Body

    var body: some View {
        TabView(selection: $model.destination) {
            Tab("Home", systemImage: "swift", value: .home) {
                NavigationStack {
                    ContentView()
                }
            }
            Tab("Profile", systemImage: "person", value: .profile) {
                NavigationStack {
                    ProfileView()
                }
            }
        }
    }

}
