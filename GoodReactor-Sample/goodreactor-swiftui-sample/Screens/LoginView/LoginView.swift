//
//  LoginView.swift
//  goodreactor-swiftui-sample
//
//  Created by Filip Šašala on 26/09/2024.
//

import SwiftUI
import NewReactor

struct LoginView: View {

    @ViewModel private var model = LoginViewModel()

    // MARK: - Wrappers

    // MARK: - View state

    // MARK: - Properties

    // MARK: - Initialization

    // MARK: - Computed properties

    // MARK: - Body

    var body: some View {
        Button {
            model.send(action: .sendLoginRequest)
        } label: {
            Text("Login")
        }
    }

}
