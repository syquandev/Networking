//
//  NetworkObserveable.swift
//  Networking
//
//  Created by BAPVN on 02/01/2024.
//

import Foundation
import Alamofire

protocol NetworkObserveable {
    var isConnectedToInternet: Bool { get }
}
class AlamoFireConnectivity: NetworkObserveable {
    
#if !(os(watchOS))
    let alamofireChecker = NetworkReachabilityManager()
    var isConnectedToInternet: Bool {
        if let checker = alamofireChecker {
            return checker.isReachable
        }
        return true
    }
#else
    var isConnectedToInternet = true
#endif

}
