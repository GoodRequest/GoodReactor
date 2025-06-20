![Logo](good-reactor.png)
 
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
        .package(url: "https://github.com/GoodRequest/GoodReactor" .upToNextMajor("2.0.0"))
    ]
)

```

# Usage
## GoodReactor

### ViewModel
In your ViewModel define Actions, Mutations, Destinations and the State

- State defines all data of a View (or a ViewController)
- Action represents user actions that are sent from the View.
- Mutation represents state changes from external sources.
- Destination represents all possible destinations, where user can navigate.

```swift
@Observable final class ViewModel: Reactor {
    enum Action {
        case login(username: String, password: String)
    }

    enum Mutation {
        case didReceiveAuthResponse(Credentials)
    }

    enum Destination {
        case homeScreen
        case errorAlert
    }

    @Observable final class State {
        var username: String
        var password: String
    }
}
```

You can provide the initial state of the view in the `makeInitialState` function.

```swift
func makeInitialState() -> State {
    return State()
}
```

Finally in the `reduce` function you define how `state` changes, according to certain `event`s:

```swift
typealias Event = GoodReactor.Event<Action, Mutation, Destination>

func reduce(state: inout State, event: Event) {
    switch event.kind {
    case .action(.login(...)):
        // ...

    case .mutation:
        // ...

    case .destination:
        // ...
    }
}
```

You can run asynchronous tasks by using `run` and returning the result in form of a `Mutation`.

```swift
func reduce(state: inout State, event: Event) {
    switch event.kind {
    case .action(.login(let username, let password)):
        run(event) {
            let credentials = await networking.login(username, password)
            return Mutation.didReceiveAuthResponse(credentials)
        }

    // ...

    case .mutation(.didReceiveAuthResponse(let credentials)):
        // proceed with login
    }
}
```

You can listen to external changes by `subscribe`-ing to event `Publisher`-s.
You start the subscriptions by calling the `start()` function.

```swift
// in ViewModel:
func transform() {
    subscribe {
        await ExternalTimer.shared.timePublisher
    } map: {
        Mutation.didChangeTime(seconds: $0)
    }
}

// in View (SwiftUI):
var body: some View {
    MyContentView()
        .task { viewModel.start() }
}
```

### View (SwiftUI)

You add the ViewModel as a property wrapper to your view:

```swift
@ViewModel private var model = MyViewModel()
```

To access the current `State` you use:

```swift
// read-only access
Text(model.username)

// binding (refactored to a variable for better readability)
let binding = model.bind(\.username, action: { .setUsername($0) })
TextField("Username",  text: binding)
```

To send an event to the ViewModel you call:

```swift
model.send(action: .login(username, password))
model.send(destination: .errorAlert)
```

### UIViewController (UIKit/Combine)

From `UIViewController` (in UIKit, or any other frameworks) you can send actions to ViewModel via Combine:
```swift
myButton.publisher(for: .touchUpInside).map { _ in .login(username, password) }
    .map { .action($0) }
    .subscribe(model.eventStream)
    .store(in: &cancellables)
```

Then use Combine to subscribe to state changes, so every time the state is changed, ViewController can be updated as well:
```swift
reactor.stateStream
    .map { String($0.username) }
    .assign(to: \.text, on: usernameLabel, ownership: .weak)
    .store(in: &cancellables)
```

## Logging
```swift
// 1. Create a logger conforming to ReactorLogger protocol
struct SampleLogger: ReactorLogger {
    
    func logReactorEvent(_ message: Any, level: LogLevel, fileName: String, lineNumber: Int) {
        print("[\(level)] \(message) (\(fileName):\(lineNumber))")
    }
    
}

// 2. Set the logger to the Reactor
@Observable final class ContentViewModel: Reactor {

    // ...
    
    func makeLogger() -> (any ReactorLogger)? {
        SampleLogger()
    }

}
```

# License
GoodReactor repository is released under the MIT license. See [LICENSE](LICENSE.md) for details.

