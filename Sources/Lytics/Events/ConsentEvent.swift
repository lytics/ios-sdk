//
//  ConsentEvent.swift
//
//  Created by Mathew Gacy on 9/19/22.
//

import AnyCodable
import Foundation

@usableFromInline
struct ConsentEvent<C: Encodable>: Encodable {
    var identifiers: [String: AnyCodable]?
    var attributes: [String: AnyCodable]?
    var consent: C?

    @usableFromInline
    init(
        identifiers: [String: AnyCodable]? = nil,
        attributes: [String: AnyCodable]? = nil,
        consent: C? = nil
    ) {
        self.identifiers = identifiers
        self.attributes = attributes
        self.consent = consent
    }
}

extension ConsentEvent: Equatable where C: Equatable {}
