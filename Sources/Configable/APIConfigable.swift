//
//  APIConfigable.swift
//  Alamofire
//
//  Created by Sỹ Quân on 26/09/2023.
//

import Foundation
public struct DebuggerConfig {
    var enableLog: Bool = false
    public static let none = DebuggerConfig(enableLog: false)
    public static let full = DebuggerConfig(enableLog: true)
}
public protocol APIConfigable {
    var ignoreReportForStatusCode: Set<Int> { get set }
    var host: String { get set }
    var debugger: DebuggerConfig { get set }
    // Prefer using default implementation for all methods below.
    func customResponseQueue() -> DispatchQueue
    func getDefinedErrors() -> [Int: Error]
}
/**
 Please check you are fully understand what you override in these extenstion below.
 All extenstion below is default for all projects, only override if you has problem with your application.
 */
public extension APIConfigable {
    /**
     Force all request to process on an specific queue.
     Default it's response in the main thread, so the UI may freeze if the response json too long(un-pagination )
     Most case you can use subcribleOn(queue) by rx to resolve
     but if you see too many places and want to fix it in lib, use this func.
     NOTE:
        - Most case just use the default implementation. Override it and you need to test your code work ok or not.
        - Only override it if your dev does not write correct rx thread on their side.
     */
    func customResponseQueue() -> DispatchQueue {
        return DispatchQueue.main
    }
    func getDefinedErrors() -> [Int: Error] {
        return [:]
    }
}

