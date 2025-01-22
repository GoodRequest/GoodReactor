//
//  DetailView.swift
//  goodreactor-swiftui-sample
//
//  Created by Filip Šašala on 11/09/2024.
//

import GoodCoordinator
import SwiftUI
import GoodReactor

struct DetailView: View {

    @ViewModel private var model = DetailViewModel()

    let value: Int

    var body: some View {
        VStack {
            Text("Detail for value \(value)")

            Button {
                #router.route(HomeViewModel.self, .profile)
            } label: {
                Text("Change path to profile")
            }

            Button {
                #router.pop(last: 3)
            } label: {
                Text("Pop three")
            }

            Button {
                model.send(destination: .detail(value - 1))
            } label: {
                Text("Push detail with one less")
            }
        }
        .navigationDestination(isPresented: $model.destinations.detail) {
            if case .detail(let value) = model.destination {
                DetailView(value: value)
            }
        }
    }

}
