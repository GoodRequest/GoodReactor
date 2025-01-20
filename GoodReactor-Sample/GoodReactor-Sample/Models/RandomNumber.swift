//
//  RandomNumber.swift
//  GoodReactor-Sample
//
//  Created by Filip Šašala on 01/09/2024.
//

import GoodNetworking

extension Int: @retroactive Placeholdable {

    public static let placeholder: Int = 0

}

struct RandomNumberResource: Readable {

    typealias ReadRequest = Void
    typealias ReadResponse = [Int]
    typealias Resource = Int

    nonisolated static func endpoint(_ request: Void) throws(NetworkError) -> any Endpoint {
        RNGEndpoint.randomNumber
    }

    nonisolated static func request(from resource: Resource?) throws(NetworkError) -> Void? {
        ()
    }

    nonisolated static func resource(from response: [Int], updating resource: Int?) throws(GoodNetworking.NetworkError) -> Int {
        if let first = response.first {
            return first
        } else {
            throw .missingRemoteData
        }
    }

}
