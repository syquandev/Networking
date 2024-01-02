//
//  RequesterMidleware.swift
//  Networking
//
//  Created by Sỹ Quân on 26/09/2023.
//

import Foundation

class RequesterMidleware {
    private var requestList: SafeSet<String> = SafeSet(value: Set<String>())
    private var cancelList: SafeSet<String> = SafeSet(value: Set<String>())
    func pushRequest(requestId: String) {
        self.requestList.insert(requestId)
    }
    func markAllRequestCancel() {
        self.requestList.forEach({self.markRequest(cancelWith: $0)})
    }
    func markRequest(cancelWith requestId: String) {
        if self.requestList.contains(requestId) {
            self.cancelList.insert(requestId)
            NNLogger.write(log: "[RequesterMidleware]Request id \(requestId) mark to cancel", logLevel: .error)
        } else {
            NNLogger.write(log: "[RequesterMidleware]Request id \(requestId) not in process, it can't be cancel",
                logLevel: .error)
        }
    }
    func removeRequestAfterCompleted(requestId: String) {
        self.requestList.remove(requestId)
        self.cancelList.remove(requestId)
    }
    func checkCancelled(requestId: String) -> Bool {
        return self.cancelList.contains(requestId)
    }
}
