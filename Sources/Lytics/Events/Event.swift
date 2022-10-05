//
//  Event.swift
//
//  Created by Mathew Gacy on 9/19/22.
//

import Foundation

struct Event<I: Encodable, P: Encodable>: Encodable {
    var name: String?
    var identifiers: I?
    var properties: P?
}
