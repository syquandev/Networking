//
//  ResponseHandleable.swift
//  Networking
//
//  Created by Sỹ Quân on 26/09/2023.
//

import Foundation
public protocol ResponseHandleable: AnyObject {
    var nextHandle: ResponseHandleable? { set get }
    var configure: APIConfigable { set get }
    var statusCode: Int { set get }

    @discardableResult
    func setNextHandle(_ handler: ResponseHandleable) -> ResponseHandleable?
    func handleResponse()
}

extension ResponseHandleable {
    @discardableResult
    public func setNextHandle(_ handler: ResponseHandleable) -> ResponseHandleable? {
        nextHandle = handler
        return nextHandle
    }
}
