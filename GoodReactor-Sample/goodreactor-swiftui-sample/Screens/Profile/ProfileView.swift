//
//  ProfileView.swift
//  goodreactor-swiftui-sample
//
//  Created by Filip Šašala on 24/09/2024.
//

import NewReactor
import GoodCoordinator
import SwiftUI

struct ProfileView: View {

    @ViewModel private var model = ProfileViewModel()

    var body: some View {
        VStack {
            Text("Profile")

            Button {
                #router.route(AppReactor.self, .loggedOut)
                #router.cleanup()
            } label: {
                Text("Logout")
            }
        }
    }

}
