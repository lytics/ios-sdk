//
//  UserUpdate.swift
//
//  Created by Mathew Gacy on 10/11/22.
//

import Foundation

struct UserUpdate<I: Encodable, A: Encodable>: Encodable {
    var identifiers: I?
    var attributes: A?

    init(identifiers: I? = nil, attributes: A? = nil) {
        self.identifiers = identifiers
        self.attributes = attributes
    }
}

extension UserUpdate: Equatable where A: Equatable, I: Equatable {}
