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

extension TestIdentifiers {
    static var user1: Self {
        .init(
            email: User1.email,
            userID: User1.userID,
            nested: Nested(a: User1.a, b: User1.b)
        )
    }
}
