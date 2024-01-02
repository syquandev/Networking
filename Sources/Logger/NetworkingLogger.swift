//
//  NetworkingLogger.swift
//  Alamofire
//
//  Created by Sỹ Quân on 26/09/2023.
//

import Foundation

enum LogLevel: Int {
    case verbose
    case warning
    case error
}
class NNLogger {

    static var logWriter: Logable = ConsoleLogger()
    static let logPrefix = "[Networking]"
    static let logWriterLevel: LogLevel = .verbose
    static func write(log: String, logLevel: LogLevel = .verbose) {
        if logWriterLevel.rawValue <= logLevel.rawValue {
            logWriter.write(log: log)
        }
    }
}
protocol Logable {
    func write(log: String)
}
/// Please use this class in case you need to write debug log into console
class ConsoleLogger: Logable {
    /// Write to the console
    /// - Parameter log: the string that will be write to screen
    func write(log: String) {
        print("\(NNLogger.logPrefix)\(log)")
    }
}
/// Please use this logger incase you need disable all the log from our system
class NullLogger: Logable {
    /// Write nothing
    /// - Parameter log: this param is not used.
    func write(log: String) {
    }
}
