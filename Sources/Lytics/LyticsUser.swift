//
//  LyticsUser.swift
//
//  Created by Mathew Gacy on 9/12/22.
//

import AnyCodable
import Foundation

/// A representation of the user.
public struct LyticsUser: Codable, Equatable {

    public enum UserType: Codable, Equatable {
        case anonymous
        case identified
    }

    /// The type of user.
    public var userType: UserType

    /// Valuable identification fields of an individual.
    public var identifiers: [String: AnyCodable]

    /// Additional information about a user.
    public var attributes: [String: AnyCodable]

    /// Initializes a user.
    /// - Parameters:
    ///   - userType: The type of user.
    ///   - identifiers: Valuable identification fields of an individual.
    ///   - attributes: Additional information about a user.
    public init(
        userType: UserType = .anonymous,
        identifiers: [String: AnyCodable] = [:],
        attributes: [String: AnyCodable] = [:]
    ) {
        self.userType = userType
        self.identifiers = identifiers
        self.attributes = attributes
    }
}

public extension LyticsUser {
    /// Initializes a user.
    /// - Parameters:
    ///   - userType: The type of user.
    ///   - identifiers: Valuable identification fields of an individual.
    ///   - attributes: Additional information about a user.
    init(
        userType: UserType = .anonymous,
        identifiers: [String: Any] = [:],
        attributes: [String: Any] = [:]
    ) {
        self.userType = userType
        self.identifiers = identifiers.mapValues(AnyCodable.init(_:))
        self.attributes = attributes.mapValues(AnyCodable.init(_:))
    }
}
