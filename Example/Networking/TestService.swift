//
//  TestService.swift
//  Networking_Example
//
//  Created by BAPVN on 02/01/2024.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import Foundation
import Networking

protocol TestServicable {
    func getTest(completionHandler: @escaping (_ data: TestResponse?,
                                               _ error: AppError?) -> Void)
}

class TestServiceImplement: TestServicable {
    var networkProvider: NetworkProvider?
    
    func getTest(completionHandler: @escaping (TestResponse?, AppError?) -> Void) {
//        guard let apiService = networkProvider else { return }
        
        let requestInput = TestInput()
        let requestOutput = TestOutput()
        let request = TestAPI(with: requestInput,
                              and: requestOutput)
        
        networkProvider?.load(api: request, onComplete: { request in
            guard let output = request.getOutput() else {
                let message = "Message"
                completionHandler(nil, AppError(code: nil,
                                                message: message,
                                                data: nil))
                return
            }

            guard let httpCode = output.result?.code, httpCode >= 200, httpCode <= 299 else {
                completionHandler(nil, AppError(code: output.result?.code,
                                                message: "",
                                                data: nil))
                return
            }
            completionHandler(output.result, nil)
        }, onRequestError: { request, _ in
            completionHandler(nil, request.output.error)
        }, onServerError: { error, _ in
            completionHandler(nil, error?.transformToAppError())
        })
    }
}

extension Error {
    func transformToAppError() -> AppError {
        return AppError(code: nil, message: "Error", data: nil)
    }
}
