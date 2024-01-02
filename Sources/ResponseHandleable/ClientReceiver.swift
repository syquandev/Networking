//
//  ClientReceiver.swift
//  Networking
//
//  Created by Sỹ Quân on 26/09/2023.
//

import Foundation
protocol ClientReceivable {
    var neoResponseHandler: ResponseHandleable? { set get }
    var boardcastIfNeeded: () -> Void { set get }
    func handleResponse()
    func shouldNotifyBoardcast() -> Bool
}

public final class ClientReceiver<T: Requestable>: ClientReceivable {
    public var neoResponseHandler: ResponseHandleable?
    public var boardcastIfNeeded: () -> Void
    public var request: T
    init(
        chainResponseHandler: ResponseHandleable?,
        boardcastIfNeeded: @escaping () -> Void,
        request: T
    ) {
        self.neoResponseHandler = chainResponseHandler
        self.boardcastIfNeeded = boardcastIfNeeded
        self.request = request
    }
    func handleResponse() {
        if shouldNotifyBoardcast() {
            boardcastIfNeeded()
        }
        neoResponseHandler?.handleResponse()
    }
    func shouldNotifyBoardcast() -> Bool {
        let isBoardcastRequestError = request.output.hasError()
            && request.output.errorServerInfomation == nil
        let isBoardcastServerError = request.output.hasError()
            && request.output.errorServerInfomation != nil
            && request.input.shouldBroadcastStatusCode()
        let shouldNotifyBoardcast = isBoardcastServerError || isBoardcastRequestError
        return shouldNotifyBoardcast
    }
}
