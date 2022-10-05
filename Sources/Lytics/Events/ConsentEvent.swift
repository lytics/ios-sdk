//
//  ConsentEvent.swift
//
//  Created by Mathew Gacy on 9/19/22.
//

import Foundation

struct ConsentEvent<I: Encodable, P: Encodable, C: Encodable>: Encodable {
    var name: String?
    var identifiers: I?
    var properties: P?
    var consent: C?
}
