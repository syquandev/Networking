import Foundation
public protocol NetworkProviable {
    var observeHeaderStatusCode: ((Int, Error?, Any?) -> Void)? { get set }
    init(with config: APIConfigable, and requester: RequesterProviable?)
    static func cancelRequest(requestId: String)
    static func cancelAllRequest()
    func load<T: Requestable>(api: T,
                                 onComplete: @escaping (T) -> Void,
                                 onRequestError: @escaping (T) -> Void,
                                 onServerError: @escaping (Error?) -> Void) -> String
    func load<T: Requestable>(api: T,
                                 onComplete: @escaping (T) -> Void,
                                 onRequestError: @escaping (T, _ errorCode: Int?) -> Void,
                                 onServerError: @escaping (Error?, _ errorCode: Int?) -> Void) -> String
}

public class NetworkProvider: NetworkProviable {
    private var config: APIConfigable
    private var requester: RequesterProviable
    private static var midleware = RequesterMidleware()
    private let networkObserveable: NetworkObserveable = AlamoFireConnectivity()
    public var observeHeaderStatusCode: ((Int, Error?, Any?) -> Void)?
    public var onNetworkUnreachable: ((Error?) -> Void)?
    public required init(with config: APIConfigable,
                         and requester: RequesterProviable? = nil) {
        self.config = config
        self.requester = requester ?? AlamofireRequesterProvider()
        if self.config.debugger.enableLog {
            NNLogger.logWriter = ConsoleLogger()
        } else {
            NNLogger.logWriter = NullLogger()
        }
        NNLogger.write(log: """
            \n--------------*****---------------------------------
            Starting Api service
            ||    - API host: \(self.config.host)
            ||    - Requester: \(type(of: self.requester))
            --------------*****---------------------------------
            """)
    }
    public static func cancelRequest(requestId: String) {
        NetworkProvider.midleware.markRequest(cancelWith: requestId)
    }
    public static func cancelAllRequest() {
        NetworkProvider.midleware.markAllRequestCancel()
    }
    @discardableResult public func load<T: Requestable>(api: T,
                                                           onComplete: @escaping (T) -> Void,
                                                           onRequestError: @escaping (T, _ errorCode: Int?) -> Void,
                                                           onServerError: @escaping (Error?, _ errorCode: Int?) -> Void)
    -> String {
        let generatedUUID = createUniqueIDForRequest()
        NetworkProvider.midleware.pushRequest(requestId: generatedUUID)
        NNLogger.write(log: "API will call: \(type(of: api.input))", logLevel: .warning)
        if !networkObserveable.isConnectedToInternet {
            NNLogger.write(log: "Internet connection error", logLevel: .error)
            onNetworkUnreachable?(self.generateNetworkError())
        } else {
            api.excute(with: self.config,
                       and: self.requester,
                       handleBy: self.config.customResponseQueue()) { [weak self] _, _, statusCode in
                guard let self = self else { return }
                if self.isBlocked(requestID: generatedUUID) {
                    return
                }
                let resultAsString = String(describing: api.output.result)
                NNLogger.write(log: "[\(type(of: api.input))][Result]: \(resultAsString))",
                               logLevel: .verbose)
                let completionHandler: ResponseHandleable = ResponseCompletion(request: api,
                                                                                     configure: self.config,
                                                                                     statusCode: statusCode,
                                                                                     onComplete: onComplete)
                let clientErrorHandler: ResponseHandleable = ResponseClientError(request: api,
                                                                                       configure: self.config,
                                                                                       statusCode: statusCode,
                                                                                       onClientError: onRequestError)
                let serverErrorHandler: ResponseHandleable = ResponseServerError(request: api,
                                                                                       configure: self.config,
                                                                                       statusCode: statusCode,
                                                                                       onServerError: onServerError)
                completionHandler
                    .setNextHandle(clientErrorHandler)?
                    .setNextHandle(serverErrorHandler)
                let clientReceiver: ClientReceivable = ClientReceiver(
                    chainResponseHandler: completionHandler,
                    boardcastIfNeeded: {
                        self.broadcast(statusCode,
                                       request: nil,
                                       responseError: api.output.error)
                    }, request: api)
                clientReceiver.handleResponse()
                NetworkProvider.midleware.removeRequestAfterCompleted(requestId: generatedUUID)
            }
        }
        return generatedUUID
    }
    @available(*, deprecated, message: "Deprecated, please consider to using the load function with status code")
    @discardableResult public func load<T>(api: T,
                                           onComplete: @escaping (T) -> Void,
                                           onRequestError: @escaping (T) -> Void,
                                           onServerError: @escaping (Error?) -> Void)
    -> String where T: Requestable {
        return load(api: api,
                    onComplete: onComplete) { type, _ in
            onRequestError(type)
        } onServerError: { error, _ in
            onServerError(error)
        }
    }
    private func isBlocked(requestID: String) -> Bool {
        let isBlocked = NetworkProvider.midleware.checkCancelled(requestId: requestID)
        NetworkProvider.midleware.removeRequestAfterCompleted(requestId: requestID)
        return isBlocked
    }
    private func createUniqueIDForRequest() -> String {
        return UUID().uuidString
    }
    private func broadcast(_ statusCode: Int, request: Error?, responseError: Any?) {
        if let concreteDelegate = self.observeHeaderStatusCode {
            concreteDelegate(statusCode, request, responseError)
        }
    }
    private func generateNetworkError() -> Error {
        return NSError(domain: "Network_unreachable",
                       code: 42,
                       userInfo: nil)
    }
}
