//
//  ViewModel.swift
//  GoodReactor
//
//  Created by Filip Šašala on 30/08/2024.
//

#if canImport(SwiftUI)
import SwiftUI

//import Observation
@available(iOS 17.0, *)
@available(macOS 14, *)
public typealias ViewModel<R: Reactor & Observable> = State<R>

@available(iOS, obsoleted: 17.0, message: "Migrate to ViewModel and Observation framework in iOS 17 and newer.")
@available(macOS, unavailable)
@MainActor @propertyWrapper public struct LegacyViewModel<Model: Reactor & ObservableObject>: DynamicProperty {

    @ObservedObject private var model: Model

    public var wrappedValue: Model {
        model
    }

    public init(wrappedValue: Model) {
        self._model = ObservedObject(initialValue: wrappedValue)
        wrappedValue.start()
    }

}
#endif
