//
//  Users.swift
//
//  Created by Mathew Gacy on 10/11/22.
//

import AnyCodable
import Foundation

enum User1 {
    static let apiKey = "at.1234"
    static let email = "someemail@lytics.com"
    static let firstName = "Jane"
    static let lastName = "Doe"
    static let userID = 1234
    static let titles = ["VP Product", "Reviewer"]
    static let a = 1
    static let b = "2"

    static let identifiers: [String: AnyCodable] = [
        "email": "someemail@lytics.com",
        "userID": 1234,
        "nested": [
            "a": a,
            "b": b
        ]
    ]

    static let attributes: [String: AnyCodable] = [
        "firstName": "Jane",
        "titles": ["VP Product", "Reviewer"]
    ]
}
