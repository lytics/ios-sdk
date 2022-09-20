//
//  LyticsUser.swift
//
//  Created by Mathew Gacy on 9/12/22.
//

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
    public var identifiers: [String: String]

    /// Additional information about a user.
    public var attributes: [String: String]

    /// Initializes a user.
    /// - Parameters:
    ///   - userType: The type of user.
    ///   - identifiers: Valuable identification fields of an individual.
    ///   - traits: Additional information about a user.
    public init(
        userType: UserType = .anonymous,
        identifiers: [String : String] = [:],
        traits: [String : String] = [:]
    ) {
        self.userType = userType
        self.identifiers = identifiers
        self.traits = traits
    }
}
