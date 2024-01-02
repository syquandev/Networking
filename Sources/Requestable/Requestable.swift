//
//  Requestable.swift
//  Networking
//
//  Created by Sỹ Quân on 26/09/2023.
//

import Alamofire
import Foundation

public typealias ApiResponse = (data: Data?, error: Error?, statusCode: Int)
public protocol Requestable {
    associatedtype OutputType: ApiOutputable
    associatedtype InputType: ApiInputable
    var input: InputType { get }
    var output: OutputType { get set }
    func excute(with config: APIConfigable,
                and requester: RequesterProviable,
                handleBy thread: DispatchQueue,
                complete: @escaping (ApiResponse) -> Void)
}
extension Requestable {
    public func excute(with config: APIConfigable,
                       and requester: RequesterProviable,
                       handleBy thread: DispatchQueue,
                       complete: @escaping (ApiResponse) -> Void) {
        let fullPathToApi = input.makeFullPathToApi(with: config)
        let neoParams = Params(path: fullPathToApi,
                                  requestType: input.requestType,
                                  headers: input.makeRequestableHeader(),
                                  params: input.makeRequestableBody(),
                                  responseThread: thread)
        self.logRequestInfo(with: fullPathToApi)
        if input.getBodyEncode() == .json {
            requester.makeRequest(params: neoParams) { response in
                self.updateResultForOutput(from: response)
                complete(response)
            }
        } else {
            requester.makeFormDataRequest(params: neoParams) { response in
                self.updateResultForOutput(from: response)
                complete(response)
            }
        }
    }
}
extension Requestable {
    private func updateResultForOutput(from response: ApiResponse) {
        
        if let data = response.data,
           let object = try? JSONSerialization.jsonObject(with: data, options: []),
           let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
           let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
            NNLogger.write(log: """
              \n----------------------JSON----------------------
              \(string)
              ----------------------********----------------------
              """)
        }
        
        self.output.convertData(from: response.data)
        if hasError(statusCode: response.statusCode) || (response.error != nil) {
            self.output.convertError(from: response.data,
                                     systemError: response.error)
        }
    }
    private func hasError(statusCode: Int) -> Bool {
        return (statusCode < 200 || statusCode > 299)
    }
    private func logRequestInfo(with path: String) {
        NNLogger.write(log: "API full api: \(path)", logLevel: .warning)
        NNLogger.write(log: "[\(type(of: self.input))][Type]: HTTP.\(self.input.requestType)", logLevel: .verbose)
        NNLogger.write(log: "[\(type(of: self.input))][Param]: \(self.input.makeRequestableBody())",
                       logLevel: .verbose)
        NNLogger.write(log: "[\(type(of: self.input))][Encode]: \(input.getBodyEncode())",
                       logLevel: .verbose)
    }
}
