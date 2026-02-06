//
//  DataFetchingState.swift
//  GoodReactor
//
//  Created by Filip Šašala on 21/10/2025.
//

public enum DataFetchingState<T, E: Error> {

    case idle
    case loading
    case success(T)
    case failure(E)

}

extension DataFetchingState {

    public var isIdle: Bool {
        switch self {
        case .idle: true
        default: false
        }
    }

    public var isLoading: Bool {
        switch self {
        case .loading: true
        default: false
        }
    }

    public var isSuccess: Bool {
        switch self {
            case .success: true
            default: false
        }
    }

    public var isFailure: Bool {
        switch self {
        case .failure: true
        default: false
        }
    }

    public var successValue: T? {
        if case .success(let value) = self {
            return value
        }
        return nil
    }

    public var errorValue: E? {
        if case .failure(let error) = self {
            return error
        }
        return nil
    }

}

extension DataFetchingState: Sendable where T: Sendable {}

extension DataFetchingState: Equatable where T: Equatable {

    nonisolated public static func == (lhs: Self, rhs: Self) -> Bool {
        switch lhs {
        case .idle:
            switch rhs {
            case .idle:
                return true

            default:
                return false
            }

        case .loading:
            switch rhs {
            case .loading:
                return true

            default:
                return false
            }

        case .success(let lhsValue):
            switch rhs {
            case .success(let rhsValue):
                return lhsValue == rhsValue

            default:
                return false
            }

        case .failure(let lhsError):
            switch rhs {
            case .failure(let rhsError):
                // TODO: improve error equality
                return lhsError.localizedDescription == rhsError.localizedDescription

            default:
                return false
            }
        }
    }

}
