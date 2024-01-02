//
//  TestAPI.swift
//  Networking_Example
//
//  Created by BAPVN on 02/01/2024.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import Foundation
import Networking

class TestAPI: Requestable {
    var input: TestInput
    var output: TestOutput
    
    init(with input: TestInput,
         and output: TestOutput) {
        self.input = input
        self.output = output
    }

    func getOutput() -> TestOutput? {
        return output
    }
}
