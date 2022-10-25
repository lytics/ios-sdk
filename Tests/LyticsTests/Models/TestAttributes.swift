//
//  TestAttributes.swift
//
//  Created by Mathew Gacy on 10/11/22.
//

import Foundation

struct TestAttributes: Codable, Equatable {
    var firstName: String?
    var lastName: String?
    var titles: [String]?
}

extension TestAttributes {
    static var user1: Self {
        .init(
            firstName: User1.firstName,
            lastName: User1.lastName,
            titles: User1.titles)
    }
}
