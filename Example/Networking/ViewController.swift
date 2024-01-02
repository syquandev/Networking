//
//  ViewController.swift
//  Networking
//
//  Created by syquandev on 09/26/2023.
//  Copyright (c) 2023 syquandev. All rights reserved.
//

import UIKit
import Networking

class ViewController: UIViewController {
    // NOTICE:
    // Example call, in real world application please dont map the API to view
    // Instead, please put these code to your service config, or inject to viewmodel file!!
    let sample = NetworkProvider(with: APIConfigableSample())
    override func viewDidLoad() {
        sample.observeHeaderStatusCode = { status, serverError, parsedError  in
            print("errorStatus code: \(status)")
        }
        sample.onNetworkUnreachable = { error in
            print("error on network call")
        }
        super.viewDidLoad()
//        let requestAuth = AuthenticateLoginAPI(with: AuthenticateLoginInput() ,
//                                               and: AuthenticateLoginOutput())
//        let requestID = sample.load(api: requestAuth,
//                    onComplete: { data in
//                        guard let result = data.output.result else { return }
//                        print(result.message ?? "i can't parse it")
//        }, onRequestError: { data, _ in
//            print("sss")
//        },
//           onServerError: { error, _ in
//        })
        let request = TestAPI(with: TestInput(), and: TestOutput())
        let requestID = sample.load(api: request) { data in
            guard let result = data.output.result else { return }
            print(result.title ?? "i can't parse it")
        } onRequestError: { data, _ in
            print("sss")
        } onServerError: { error, _ in
            
        }

        NetworkProvider.cancelAllRequest()
        //NeoNetworkProvider.cancelRequest(requestId: requestID)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

class APIConfigableSample: APIConfigable {
    var ignoreReportForStatusCode: Set<Int> = [401, 403, 503]
    var host: String = "https://germaneverydayonline.com/api/"
    var debugger: DebuggerConfig = .full
    
    func customResponseQueue() -> DispatchQueue {
        return .init(label: "APIConfigableSample.Test",
                     qos: .userInteractive,
                     attributes: .concurrent)
    }
}
