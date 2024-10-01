//
//  RNGEndpoint.swift
//  GoodReactor-Sample
//
//  Created by Filip Šašala on 01/09/2024.
//

import Alamofire
import Foundation
import GoodNetworking

// https://www.randomnumberapi.com/api/v1.0/random?min=1&max=100

enum RNGEndpoint: Endpoint {

    case randomNumber

    var path: String {
        "https://www.randomnumberapi.com/api/v1.0/random"
    }

    var method: Alamofire.HTTPMethod {
        return .get
    }

    var parameters: GoodNetworking.EndpointParameters? {
        return .parameters([
            "min": "0",
            "max": "100"
        ])
    }

    var headers: Alamofire.HTTPHeaders? {
        nil
    }

    var encoding: any Alamofire.ParameterEncoding {
        return URLEncoding.default
    }

    func url(on _: String) throws -> URL {
        return try path.asURL()
    }

}
