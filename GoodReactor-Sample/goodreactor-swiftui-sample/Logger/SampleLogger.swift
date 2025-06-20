//
//  SampleLogger.swift
//  goodreactor-swiftui-sample
//
//  Created by Matus Klasovity on 23/06/2025.
//

import GoodReactor

struct SampleLogger: ReactorLogger {

    func logReactorEvent(_ message: Any, level: GoodReactor.LogLevel, fileName: String, lineNumber: Int) {
        print("\(level): \(message) [\(fileName):\(lineNumber)]")
    }
    
}
