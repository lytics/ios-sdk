//
//  ScreenEvent.swift
//
//  Created by Mathew Gacy on 10/16/22.
//

import AnyCodable
import Foundation

@usableFromInline
struct ScreenEvent<P: Encodable>: Encodable {
    var device: Device
    var identifiers: [String: AnyCodable]?
    var properties: P?

    @usableFromInline
    init(
        device: Device,
        identifiers: [String: AnyCodable]? = nil,
        properties: P? = nil
    ) {
        self.device = device
        self.identifiers = identifiers
        self.properties = properties
    }
}

extension ScreenEvent: Equatable where P: Equatable {}
