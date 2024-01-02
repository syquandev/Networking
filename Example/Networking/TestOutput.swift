//
//  TestOutput.swift
//  Networking_Example
//
//  Created by BAPVN on 02/01/2024.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import Foundation
import Networking

class TestOutput: ApiOutputable {
    var result: TestResponse?
    var error: AppError?
    var systemError: Error?
    var responseParser: Parseable = CodeableParser<ResultType>()
    var errorParser: Parseable = CodeableParser<ErrorType>()
}

struct AppError: Codable, Error {
    var code: Int?
    var message: String?
    var data: AppErrorData?
}

// MARK: - AppErrorData

struct AppErrorData: Codable {
    let type: String?
}

// MARK: - CheckVersionResponse
struct TestResponse: Codable {
    let code: Int?
    let id: Int?
    let title: String?
    
    enum CodingKeys: String, CodingKey {
        case id, title, code
    }
}

//var number: Int?
//var title, startDate, endDate, type, location: String?
//var qualifications: String?
//var contactName: String?
//var contactEmail: String?
//var category: Category?
//number <- map["id"]
//title <- map["title"]
//startDate <- map["startDate"]
//endDate <- map["endDate"]
//location <- map["location"]
//type <- map["type"]
//qualifications <- map["qualifications"]
//contactName <- map["contactName"]
//contactEmail <- map["contactEmail"]
//category <- map["category"]
