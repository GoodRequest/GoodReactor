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

    @ViewModel var viewModel: DetailViewModel

    var body: some View {
        VStack {
            Text("Detail for value \(viewModel.studentsCount)")

            Button {
                viewModel.send(action: .increment)
            } label: {
                Text("Increment")
            }

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
                viewModel.send(destination: .detail(-1/*viewModel.value - 1*/))
            } label: {
                Text("Push detail with one less")
            }
        }
        .navigationDestination(isPresented: $viewModel.destinations.detail) {
            if case .detail(let value) = viewModel.destination {
                DetailView(viewModel: DetailViewModel())
            }
        }
    }

}
