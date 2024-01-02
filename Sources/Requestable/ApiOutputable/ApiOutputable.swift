//
//  ApiOutputable.swift
//  Networking
//
//  Created by Sỹ Quân on 26/09/2023.
//

import Foundation
public protocol ApiOutputable: class {
    associatedtype ResultType
    associatedtype ErrorType
    var responseParser: Parseable { get set }
    var errorParser: Parseable { get set }
    var result: ResultType? { get set }
    var error: ErrorType? { get set }
    func convertData(from data: Data?)
    func convertError(from data: Data?, systemError: Error?)
    func hasError() -> Bool
}
struct AssociatedKeys {
    static var errorServer: UInt8 = 0
}
public extension ApiOutputable {
    private(set) var errorServerInfomation: Error? {
        set {
             objc_setAssociatedObject(self,
                                      &AssociatedKeys.errorServer, newValue,
                                      objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            guard let value = objc_getAssociatedObject(self, &AssociatedKeys.errorServer) as? Error else {
                return nil
            }
            return value
        }
    }
    func convertData(from data: Data?) {
        guard let concreteData = data else {
            return
        }
        self.result = responseParser.parse(concreteData)
    }
    func convertError(from data: Data?, systemError: Error?) {
        self.errorServerInfomation = systemError
        guard let concreteData = data else {
            return
        }
        self.error = errorParser.parse(concreteData)
    }
    func hasError() -> Bool {
        return (self.errorServerInfomation != nil) || (self.error != nil)
    }
}
