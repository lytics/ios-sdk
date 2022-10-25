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

    static let anyIdentifiers: [String: Any] = [
        "email": "someemail@lytics.com",
        "userID": 1234,
        "nested": [
            "a": a,
            "b": b
        ]
    ]

    static var identifiers: [String: AnyCodable] {
        anyIdentifiers.mapValues(AnyCodable.init(_:))
    }

    static let anyAttributes: [String: Any] = [
        "firstName": "Jane",
        "titles": ["VP Product", "Reviewer"]
    ]

    static var attributes: [String: AnyCodable] {
        anyAttributes.mapValues(AnyCodable.init(_:))
    }
}
