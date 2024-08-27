//
//  Coordinator.swift
//  GoodReactor
//
//  Created by Filip Šašala on 09/09/2024.
//

import SwiftUI

@MainActor public protocol Screen: View {

}

@MainActor public protocol Coordinator {

    associatedtype R: Reactor
    associatedtype S: Screen

    @ViewBuilder func makeScreen() -> S

}
