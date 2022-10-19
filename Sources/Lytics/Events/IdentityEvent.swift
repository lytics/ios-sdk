//
//  IdentityEvent.swift
//
//  Created by Mathew Gacy on 9/19/22.
//

import Foundation

@usableFromInline
struct IdentityEvent<I: Encodable, A: Encodable>: StreamEvent {
    var stream: String
    var name: String?
    var identifiers: I?
    var attributes: A?

    @usableFromInline
    init(stream: String, name: String? = nil, identifiers: I? = nil, attributes: A? = nil) {
        self.stream = stream
        self.name = name
        self.identifiers = identifiers
        self.attributes = attributes
    }

    private enum CodingKeys: CodingKey {
        case name
        case identifiers
        case attributes
    }
}

extension IdentityEvent: Equatable where I: Equatable, A: Equatable {}
