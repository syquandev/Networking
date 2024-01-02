//
//  AlamofireRequester.swift
//  Networking
//
//  Created by Sỹ Quân on 26/09/2023.
//

import Foundation
import Alamofire

public struct Params {
    let path: String
    let requestType: RequestType
    let headers: [String: String]
    let params: [String: Any]
    let responseThread: DispatchQueue
}

public protocol RequesterProviable {
    func makeRequest(params: Params,
                     complete: @escaping (ApiResponse) -> Void)
    func makeFormDataRequest(params: Params,
                             complete: @escaping (ApiResponse) -> Void)
}
public class AlamofireRequesterProvider: RequesterProviable {
    static let sessionManager: Session = {
        let configuration = URLSessionConfiguration.af.ephemeral
        return Session(configuration: configuration)
    }()

    public func makeRequest(params: Params,
                            complete: @escaping (ApiResponse) -> Void) {
        AlamofireRequesterProvider.sessionManager.request(params.path,
                   method: HTTPMethod(rawValue: params.requestType.rawValue),
                   parameters: params.params,
                   encoding: (params.requestType == .get) ? URLEncoding.default : JSONEncoding.default,
                   headers: HTTPHeaders(params.headers)
        ).responseJSON(queue: params.responseThread) { response in
            complete((response.data, response.error, response.response?.statusCode ?? 200))
        }
    }
    public func makeFormDataRequest(params: Params,
                                    complete: @escaping (ApiResponse) -> Void) {
        AlamofireRequesterProvider.sessionManager.upload(
            multipartFormData: { formData in
                for param in params.params {
                    if let string = param.value as? String,
                       let stringData = string.data(using: .utf8) {
                        formData.append(stringData, withName: param.key)
                    }
                    if let fileData = param.value as? Data {
                        formData.append(fileData, withName: param.key, fileName: "upload_image.png")
                    }
                }
            },
            to: params.path,
            method: HTTPMethod(rawValue: params.requestType.rawValue),
            headers: HTTPHeaders(params.headers)
        ).responseJSON(queue: params.responseThread) { response in
            if let dataConcrete = response.data {
                NNLogger.write(log: "[Error]: \(String(decoding: dataConcrete, as: UTF8.self))",
                               logLevel: .error)
            }
            complete((response.data, response.error, response.response?.statusCode ?? 200))
        }
    }
}
