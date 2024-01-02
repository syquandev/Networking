//
//  ResponseServerError.swift
//  Networking
//
//  Created by Sỹ Quân on 26/09/2023.
//

import Foundation

public final class ResponseServerError<T: Requestable>: ResponseHandleable {
    public var nextHandle: ResponseHandleable?
    public var request: T
    public var configure: APIConfigable
    public var onServerError: (Error?, _ statusCode: Int?) -> Void
    public var statusCode: Int
    init(
        request: T,
        configure: APIConfigable,
        statusCode: Int,
        onServerError: @escaping (Error?, _ statusCode: Int?) -> Void
    ) {
        self.request = request
        self.configure = configure
        self.statusCode = statusCode
        self.onServerError = onServerError
    }
    public func handleResponse() {
        let shouldNotifyServerError = request.output.errorServerInfomation != nil
        let errorResponse = configure.getDefinedErrors()[statusCode] ?? request.output.errorServerInfomation
        if shouldNotifyServerError {
            onServerError(errorResponse, statusCode)
        } else {
            nextHandle?.handleResponse()
        }
    }
}
