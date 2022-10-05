//
//  ConsentEvent.swift
//
//  Created by Mathew Gacy on 9/19/22.
//

import Foundation

struct ConsentEvent<I: Encodable, A: Encodable, C: Encodable>: Encodable {
    var name: String?
    var identifiers: I?
    var attributes: A?
    var consent: C?
}
