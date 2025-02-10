//
//  ProfileViewModel.swift
//  goodreactor-swiftui-sample
//
//  Created by Filip Šašala on 24/09/2024.
//

import Foundation
import GoodCoordinator
import GoodReactor
import Observation

@Observable final class ProfileViewModel: Reactor {

    typealias Event = GoodReactor.Event<Action, Mutation, Destination>

    enum Action {

        case changeUsername(String)

    }

    enum Mutation {

    }

    @MainActor @Observable final class State {

        @Shared(default: 0)
        @ObservationIgnored
        var studentsCount: Int

        // MARK: - profile

//        private struct __Key_Shared_profile: SharedStateKey {
//            static var defaultValue: Profile { Profile() }
//        }
//        private let __key_shared_profile = __Key_Shared_profile()
//
//        var profile: Profile {
//            get {
//                _$observationRegistrar.access(self, keyPath: \.profile)
//                return GlobalScope.global[__key_shared_profile]
//            }
//            set {
//                _$observationRegistrar.willSet(self, keyPath: \.profile)
//                GlobalScope.global[__key_shared_profile] = newValue
//                _$observationRegistrar.didSet(self, keyPath: \.profile)
//            }
//        }

    }

    @Navigable enum Destination {

    }

    func makeInitialState() -> State {
        return State()
    }

    func reduce(state: inout State, event: Event) {
        switch event.kind {
        case .action(.changeUsername(let newUsername)):
//            state.profile.username = newUsername
            print(newUsername)

        default:
            break
        }
    }

}

