//
//  DemoIdentity.swift
//
//  Created by Mathew Gacy on 10/5/22.
//

import Foundation

struct DemoIdentity: Codable, Equatable {
    var userID: String
    var email: String

    init(userID: String = "", email: String = "") {
        self.userID = userID
        self.email = email
    }
}
