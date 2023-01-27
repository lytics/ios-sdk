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
    public var attributes: [String: AnyCodable]?

    /// The user entity.
    public var profile: [String: AnyCodable]?

    /// Initializes a user.
    /// - Parameters:
    ///   - identifiers: Valuable identification fields of an individual.
    ///   - attributes: Additional information about a user.
    ///   - profile: The user entity.
    public init(
        identifiers: [String: AnyCodable] = [:],
        attributes: [String: AnyCodable]? = nil,
        profile: [String: AnyCodable]? = nil
    ) {
        self.identifiers = identifiers
        self.attributes = attributes
        self.profile = profile
    }
}

public extension LyticsUser {

    /// Initializes a user.
    /// - Parameters:
    ///   - identifiers: Valuable identification fields of an individual.
    ///   - attributes: Additional information about a user.
    ///   - profile: The user entity.
    init(
        identifiers: [String: Any] = [:],
        attributes: [String: Any]? = nil,
        profile: [String: Any]? = nil
    ) {
        self.identifiers = identifiers.mapValues(AnyCodable.init(_:))
        self.attributes = attributes?.mapValues(AnyCodable.init(_:))
        self.profile = profile?.mapValues(AnyCodable.init(_:))
    }
}
