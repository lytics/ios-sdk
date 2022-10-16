//
//  TestIdentifiers.swift
//
//  Created by Mathew Gacy on 10/11/22.
//

import Foundation

struct TestIdentifiers: Codable, Equatable {
    struct Nested: Codable, Equatable {
        var a: Int
        var b: String
    }

    var email: String?
    var userID: Int?
    var nested: Nested?
}
