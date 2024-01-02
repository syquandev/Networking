//
//  ApiInputable.swift
//  Networking
//
//  Created by Sỹ Quân on 26/09/2023.
//

import Foundation

public enum RequestType: String {
    case get = "GET"
    case post = "POST"
    case delete = "DELETE"
    case put = "PUT"// the form data
    case patch = "PATCH"
}

public enum BodyEncode {
    case formdata
    case json
}
/* This protocol hold all the logical of input data for the request
 
 - Parameters:
 - requestType: The type of HTTP request, it should be: get/post/put/delete....
 - pathToApi: The leading path to API, normally the path is https://somehost.com/api/somepath/somepath
 and the value of it is /somepath/domepath
 */
public protocol ApiInputable {
    var requestType: RequestType { get }
    var pathToApi: String { get }
    /* [makeFullPathToApi(:)] :This function will create the full api path to server,
     Some value is common and it put inside the configuration class
     The path from your setting in this protocol implementation.
     
     - Parameters:
     - config: The application config.
     */
    func makeFullPathToApi(with config: APIConfigable) -> String
    /* [makeRequestableBody()] :This function create the body for this request.
     All paramenters should be put as [key: value] on this return
     */
    func makeRequestableBody() -> [String: Any]
    /* [makeRequestableHeader()] :This function create the header for this request.
     All headers should be put as [key: value] on this return
     */
    func makeRequestableHeader() -> [String: String]
    /* [makeUrlParamReplace()] :This function create the path for this request.
     Some times the backend service add dynamic path, we need to replace it to run the api:
     Example: the path is: https://somehost.com/api/{{userID}}/profile.
     so we can make the return is ["{{userID}}":123], with 123 is the dynamic information
     */
    func makeUrlParamReplace() -> [String: String]
    func getBodyEncode() -> BodyEncode
    /* This function controlled broadcast state of request
    Default all request will not broadcast error
    Override it if you need to control the whole logic from app
    */
    func shouldBroadcastStatusCode() -> Bool
}
extension ApiInputable {
    public func getBodyEncode() -> BodyEncode {
        return .json
    }
    public func shouldBroadcastStatusCode() -> Bool {
        return true
    }
    /*
     Default implemention for makeFullPathToApi()
    */
    public func makeFullPathToApi(with config: APIConfigable) -> String {
        var result = config.host + self.pathToApi
        self.makeUrlParamReplace().forEach({result = result.replacingOccurrences(of: $0.key,
                                                                                 with: $0.value)})
        return result
    }
    /*
     Default implemention for makeUrlParamReplace(): Nothing changed for the request
    */
    public func makeUrlParamReplace() -> [String: String] {
        return [:]
    }
}
