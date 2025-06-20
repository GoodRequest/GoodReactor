//
//  ReactorConfiguration.swift
//  GoodReactor
//
//  Created by Matus Klasovity on 09/06/2025.
//

import Foundation

@MainActor
public struct ReactorConfiguration: Sendable {
    
    private init() {}
    
    public static var logger: ReactorLogger? = nil
    
}
