//
//  ReactorLogger.swift
//  GoodReactor
//
//  Created by Matus Klasovity on 09/06/2025.
//

import Foundation

public enum LogLevel {
    case debug
}

public protocol ReactorLogger: Sendable {
    
    func logReactorEvent(_ message: Any, level: LogLevel, fileName: String, lineNumber: Int)
        
}
