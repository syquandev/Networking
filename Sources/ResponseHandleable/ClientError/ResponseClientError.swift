//
//  ResponseClientError.swift
//  Networking
//
//  Created by Sỹ Quân on 26/09/2023.
//

import Foundation
public final class ResponseClientError<T: Requestable>: ResponseHandleable {
    public var nextHandle: ResponseHandleable?
    public var request: T
    public var configure: APIConfigable
    public var onClientError: (T, _ statusCode: Int?) -> Void
    public var statusCode: Int
    init(
        request: T,
        configure: APIConfigable,
        statusCode: Int,
        onClientError: @escaping (T, _ statusCode: Int?) -> Void
    ) {
        self.request = request
        self.configure = configure
        self.statusCode = statusCode
        self.onClientError = onClientError
    }
    public func handleResponse() {
        let shouldNotifyClientError = request.output.errorServerInfomation == nil
        if shouldNotifyClientError {
            onClientError(request, statusCode)
        } else {
            nextHandle?.handleResponse()
        }
    }
}
