//
//  DetailViewModel.swift
//  GoodReactor-Sample
//
//  Created by Filip Šašala on 11/09/2024.
//

import GoodCoordinator
import GoodReactor
import Observation

@Observable final class DetailViewModel: Reactor {
    
    typealias Event = GoodReactor.Event<Action, Mutation, Destination>
    
    enum Action {
        
        case increment
        
    }
    
    enum Mutation {
        
    }
    
    @Navigable enum Destination {
        
        case detail(Int)
        
    }
    
    @MainActor @Observable final class State {

        @Shared(default: 0)
        @ObservationIgnored
        var studentsCount: Int

    }

//    unowned var parent: any Reactor

//    init(super reactor: any Reactor) {
//        self.parent = reactor
//    }

    func makeInitialState() -> State {
        State()
    }
    
    func reduce(state: inout State, event: Event) {
        switch event.kind {
        case .action(.increment):
            state.studentsCount += 1
            
        default:
            break
        }
    }
    
}
