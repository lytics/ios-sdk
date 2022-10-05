//
//  IdentityEvent.swift
//
//  Created by Mathew Gacy on 9/19/22.
//

import Foundation

struct IdentityEvent<I: Encodable, A: Encodable>: Encodable {
    var name: String?
    var identifiers: I?
    var attributes: A?
}
