//
//  Event.swift
//
//  Created by Mathew Gacy on 9/19/22.
//

import AnyCodable
import Foundation

@usableFromInline
struct Event<P: Encodable>: StreamEvent {
    var stream: String
    var name: String?
    var identifiers: [String: AnyCodable]?
    var properties: P?

    @usableFromInline
    init(
        stream: String,
        name: String? = nil,
        identifiers: [String: AnyCodable]? = nil,
        properties: P? = nil
    ) {
        self.stream = stream
        self.name = name
        self.identifiers = identifiers
        self.properties = properties
    }

    private enum CodingKeys: CodingKey {
        case name
        case identifiers
        case properties
    }
}
