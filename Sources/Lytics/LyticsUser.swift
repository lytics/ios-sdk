//
//  LyticsUser.swift
//
//  Created by Mathew Gacy on 9/12/22.
//

import AnyCodable
import Foundation

/// A representation of the user.
public struct LyticsUser: Codable, Equatable {

    /// Valuable identification fields of an individual.
    public var identifiers: [String: AnyCodable]

    /// Additional information about a user.
    public var attributes: [String: AnyCodable]

    /// Initializes a user.
    /// - Parameters:
    ///   - identifiers: Valuable identification fields of an individual.
    ///   - attributes: Additional information about a user.
    public init(
        identifiers: [String: AnyCodable] = [:],
        attributes: [String: AnyCodable] = [:]
    ) {
        self.identifiers = identifiers
        self.attributes = attributes
    }
}

public extension LyticsUser {

    /// Initializes a user.
    /// - Parameters:
    ///   - identifiers: Valuable identification fields of an individual.
    ///   - attributes: Additional information about a user.
    init(
        identifiers: [String: Any] = [:],
        attributes: [String: Any] = [:]
    ) {
        self.identifiers = identifiers.mapValues(AnyCodable.init(_:))
        self.attributes = attributes.mapValues(AnyCodable.init(_:))
    }
}
