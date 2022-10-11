//
//  ConsentEvent.swift
//
//  Created by Mathew Gacy on 9/19/22.
//

import AnyCodable
import Foundation

struct ConsentEvent<C: Encodable>: Encodable {
    var stream: String
    var name: String?
    var identifiers: [String: AnyCodable]?
    var attributes: [String: AnyCodable]?
    var consent: C?

    init(
        stream: String,
        name: String? = nil,
        identifiers: [String: AnyCodable]? = nil,
        attributes: [String: AnyCodable]? = nil,
        consent: C? = nil
    ) {
        self.stream = stream
        self.name = name
        self.identifiers = identifiers
        self.attributes = attributes
        self.consent = consent
    }

    private enum CodingKeys: CodingKey {
        case name
        case identifiers
        case attributes
        case consent
    }
}
