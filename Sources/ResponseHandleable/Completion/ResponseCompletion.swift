//
//  ResponseCompletion.swift
//  Networking
//
//  Created by Sỹ Quân on 26/09/2023.
//

import Foundation

public final class ResponseCompletion<T: Requestable>: ResponseHandleable {
    public var nextHandle: ResponseHandleable?
    public var configure: APIConfigable
    public var onComplete: (T) -> Void
    public let request: T
    public var statusCode: Int
    init(
        request: T,
        configure: APIConfigable,
        statusCode: Int,
        onComplete: @escaping (T) -> Void
    ) {
        self.request = request
        self.configure = configure
        self.onComplete = onComplete
        self.statusCode = statusCode
    }
    public func handleResponse() {
        if !request.output.hasError() {
            onComplete(request)
        } else if request.output.hasError() && !configure.ignoreReportForStatusCode.contains(statusCode) {
            nextHandle?.handleResponse()
        }
    }
}

