//
//  Event.swift
//
//  Created by Mathew Gacy on 9/19/22.
//

import AnyCodable
import Foundation

@usableFromInline
struct Event<P: Encodable>: Encodable {
    var identifiers: [String: AnyCodable]?
    var properties: P?

    @usableFromInline
    init(
        identifiers: [String: AnyCodable]? = nil,
        properties: P? = nil
    ) {
        self.identifiers = identifiers
        self.properties = properties
    }
}

// MARK: Equatable
extension Event: Equatable where P: Equatable {}
