# GoodReactor

[Check out the Documentation](https://goodrequest.github.io/GoodReactor/documentation/goodreactor/)

[![iOS Version](https://img.shields.io/badge/iOS_Version->=_12.0-brightgreen?logo=apple&logoColor=green)]() 
[![Swift Version](https://img.shields.io/badge/Swift_Version-5.5-green?logo=swift)](https://docs.swift.org/swift-book/)
[![Supported devices](https://img.shields.io/badge/Supported_Devices-iPhone/iPad-green)]()
[![Contains Test](https://img.shields.io/badge/Tests-YES-blue)]()
[![Dependency Manager](https://img.shields.io/badge/Dependency_Manager-SPM-red)](#swiftpackagemanager)

GoodReactor is an adaptation of the Reactor framework that is Redux inspired.
The view model communicates with the view controller via the State and with the Coordinator via the navigation function.
You communicate to the viewModel via Actions
Viewmodel changes state in the Reduce function
Viewmodel interactes with dependencies outside of the Reduce function not to create side-effects

Link to the original reactor kit: https://github.com/ReactorKit/ReactorKit


# Installation
## Swift Package Manager

Create a `Package.swift` file and add the package dependency into the dependencies list.
Or to integrate without package.swift add it through the Xcode add package interface.

```swift

import PackageDescription

let package = Package(
    name: "SampleProject",
    dependencies: [
        .Package(url: "https://github.com/GoodRequest/GoodReactor" from: "addVersion")
    ]
)

```

# Usage
## GoodReactor

### ViewModel
In your ViewModel define State, Actions and Mutations

- State defines all data that you work with
- Action user actions that are sent from the ViewController.
- Mutation represents state changes.

```swift
    struct State {

        var counterValue: Int

    }

    enum Action {

        case updateCounterValue(CounterMode)
        case goToAbout

    }

    enum Mutation {

        case counterValueUpdated(Int)

    }
```

In the `mutate` function define what will happen when certain actions are called:

```swift
func mutate(action: Action) -> AnyPublisher<Mutation, Never> {
    switch action {
        case .updateCounterValue(let mode):
        return updateCounter(mode: mode)
        }
}
    
func updateCounter(mode: CounterMode) -> AnyPublisher<Mutation,Never> {
    var actualValue = currentState.counterValue

    switch mode {
        case .increase:
        actualValue += 1

        case .decrease:
        actualValue -= 1
    }

    return Just(.counterValueUpdated(actualValue)).eraseToAnyPublisher()
}

```

Finally in the `reduce` function define `state` changes according to certain `mutation`:
```swift
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state

        switch mutation {
        case .counterValueUpdated(let newValue):
            state.counterValue = newValue
        }

        return state
    }
```

### ViewController

From `ViewController` you can send actions to `ViewModel` via Combine just like in our `GoodReactor-Sample` or like this:
```swift
viewModel.send(event: yourAction)
```

Then use combine to subscribe to state changes, so every time the state is changed, ViewController is updated as well:
```swift
viewModel.state
    .map { String($0.counterValue) }
    .removeDuplicates()
    .assign(to: \.text, on: counterValueLabel, ownership: .weak)
    .store(in: &cancellables)

```

## GoodCoordinator
When viewModel's action is called, navigation function is called as well. There you can hande the app flow, for example:
```swift
func navigate(action: Action) -> AppStep? {
    switch action {
        case .goToAbout:
        return .home(.goToAbout)

        default:
        return .none
    }
}
```

# License
GoodReactor repository is released under the MIT license. See [LICENSE](LICENSE.md) for details.

