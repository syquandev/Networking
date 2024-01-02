//
//  TestInput.swift
//  Networking_Example
//
//  Created by BAPVN on 02/01/2024.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import Foundation
import Networking

class TestInput: ApiInputable {
    var requestType: RequestType = .get
    
    var pathToApi: String = "ausbildung"
    
    func makeRequestableBody() -> [String : Any] {
        return [:]
    }
    
    func makeRequestableHeader() -> [String : String] {
        return [:]
    }
}
