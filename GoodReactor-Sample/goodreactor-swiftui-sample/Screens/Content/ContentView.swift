//
//  ContentView.swift
//  goodreactor-swiftui-sample
//
//  Created by Filip Šašala on 07/09/2024.
//

import GoodCoordinator
import NewReactor
import SwiftUI

struct ContentView: View {

    @ViewModel var model = ContentViewModel()

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)

            Text(model.text)
            Text("Value: \(model.counter)")
            Text("Error: \(model.destinations.errorAlert)")

            Button {
                model.send(destination: .presentSheet)
            } label: {
                Text("Present")
            }

            Button {
                model.send(destination: .presentSheet2)
            } label: {
                Text("Present other")
            }

            Button {
                model.send(destination: .pushScreen)
            } label: {
                Text("Push")
            }

            Button {
                model.send(destination: .errorAlert)
            } label: {
                Text("Error alert")
            }

            Button {
                model.send(destination: .confirmationDialog)
            } label: {
                Text("Confirmation dialog")
            }

            Divider()
            TextField("Text", text: model.bind(\.text, action: { .setText($0) })).padding()
            Divider()

            Button {
                model.send(destination: .detail(3))
            } label: {
                Text("Go to detail")
            }

            Button {
                #router.route(HomeViewModel.self, .profile)
            } label: {
                Text("Go to profile")
            }

            Button {
                #router.pop()
            } label: {
                Text("Try to pop a Tab")
            }

            Button {
                #router.route(
                    type: HomeViewModel.self,
                          ContentViewModel.self,
                    destination: .home,
                                 .detail(8)
                )
            } label: {
                Text("Go 3 levels deep")
            }
        }
        .padding()
        .sheet(isPresented: $model.destinations.presentSheet, content: {
            VStack {
                Text("Present sheet")
                Button {
                    model.send(destination: .pushScreen)
                } label: {
                    Text("Go to pushed screen")
                }
            }
        })
        .sheet(isPresented: $model.destinations.presentSheet2, content: {
            VStack {
                Text("Other sheet")
                Button {
                    model.send(destination: .presentSheet)
                } label: {
                    Text("Go to first sheet")
                }
            }
        })
        .navigationDestination(isPresented: $model.destinations.pushScreen, destination: {
            VStack {
                Text("Push screen")
                Button {
                    model.send(destination: .presentSheet)
                } label: {
                    Text("Go to presented screen")
                }
            }
        })
        .navigationDestination(isPresented: $model.destinations.detail, destination: {
            if case .detail(let value) = model.destination {
                DetailView(value: value)
            }
        })
        .alert("Error", isPresented: $model.destinations.errorAlert) {
            Button("Cancel", role: .cancel) {}
        }
        .confirmationDialog("Confirm action", isPresented: $model.destinations.confirmationDialog) {
            Button("OK", role: .none) {}
            Button("Delete", role: .destructive) {
                model.send(destination: .presentSheet)
            }
        }
    }
}

#Preview {
    ContentView()
}
