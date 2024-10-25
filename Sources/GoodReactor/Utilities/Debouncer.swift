//
//  Debouncer.swift
//  GoodReactor
//
//  Created by Filip Šašala on 25/10/2024.
//

import Foundation

/// Executes an output only after a specified time interval elapses between events
///
/// ```swift
/// let debouncer = Debouncer<Int>(dueTime: .seconds(2), output: { print($0) })
///
/// for index in (0...99) {
///   DispatchQueue.global().asyncAfter(deadline: .now().advanced(by: .milliseconds(100 * index))) {
///     // pushes a value every 100 ms
///     debouncer.push(index)
///   }
/// }
///
/// // will only print "99" 2 seconds after the last call to `push(_:)`
/// ```
public actor Debouncer<Value: Sendable> {

    // MARK: - Enums

    typealias DueValue = (value: Value, dueTime: DispatchTime)

    enum State {

        case idle
        case debouncing(value: DueValue, nextValue: DueValue?)

    }

    enum DebouncingResult {

        case continueDebouncing(DueValue)
        case finishDebouncing

    }

    // MARK: - Properties

    public var outputHandler: (@isolated(any) (Value) async -> Void)?
    public var timeInterval: DispatchTimeInterval

    private var state: State
    private var task: Task<Void, Never>?

    // MARK: - Initialization

    /// A debouncer that executes output only after a specified time has elapsed between events.
    /// - Parameters:
    ///   - delay: How long the debouncer should wait before executing the output
    ///   - outputHandler: Handler to execute once the debouncing is done
    public init(
        delay timeInterval: DispatchTimeInterval = .never,
        @_implicitSelfCapture outputHandler: (@isolated(any) @Sendable (Value) async -> Void)? = nil
    ) {
        self.state = .idle
        self.timeInterval = timeInterval
        self.outputHandler = outputHandler
    }

    deinit {
        print("cancelling task")
        task?.cancel()
    }

}

// MARK: - Public

public extension Debouncer {

    /// Send an updated value to debouncer.
    func push(_ value: Value) {
        let newValue = DueValue(value: value, dueTime: DispatchTime.now().advanced(by: timeInterval))

        switch self.state {
        case .idle:
            self.state = .debouncing(value: newValue, nextValue: nil)
            self.task = makeNewDebouncingTask(value)

        case .debouncing(let current, _):
            self.state = .debouncing(value: current, nextValue: newValue)
        }
    }

}

// MARK: - Private

private extension Debouncer {

    private func makeNewDebouncingTask(_ value: Value) -> Task<Void, Never> {
        return Task<Void, Never> {
            var timeToSleep = timeInterval.nanoseconds
            var currentValue = value

            loop: while true {
                try? await Task.sleep(nanoseconds: timeToSleep)

                let result: DebouncingResult
                switch self.state {
                case .idle:
                    assertionFailure("inconsistent state, a value was being debounced")
                    result = .finishDebouncing

                case .debouncing(_, nextValue: .some(let nextValue)):
                    state = .debouncing(value: nextValue, nextValue: nil)
                    result = .continueDebouncing(nextValue)

                case .debouncing(_, nextValue: .none):
                    state = .idle
                    result = .finishDebouncing
                }

                switch result {
                case .finishDebouncing:
                    break loop

                case .continueDebouncing(let value):
                    timeToSleep = DispatchTime.now().distance(to: value.dueTime).nanoseconds
                    currentValue = value.value
                }
            }

            await outputHandler?(currentValue)
        }
    }

}

// MARK: - Extensions

fileprivate extension DispatchTimeInterval {

    var nanoseconds: UInt64 {
        switch self {
        case .nanoseconds(let value) where value >= 0:
            return UInt64(value)

        case .microseconds(let value) where value >= 0:
            return UInt64(value) * 1000

        case .milliseconds(let value) where value >= 0:
            return UInt64(value) * 1_000_000

        case .seconds(let value) where value >= 0:
            return UInt64(value) * 1_000_000_000

        case .never:
            return .zero

        default:
            return .zero
        }
    }

}

// MARK: - Identifier

internal typealias DebouncerIdentifier = CodeLocationIdentifier
