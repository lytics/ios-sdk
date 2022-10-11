//
//  UserManaging.swift
//
//  Created by Mathew Gacy on 10/11/22.
//

import AnyCodable
import Foundation

/// A type that manages user identifiers and attributes.
protocol UserManaging: Actor {

    /// Returns the user attributes.
    var attributes: [String: Any] { get }

    /// Returns the user identifiers.
    var identifiers: [String: Any] { get }

    @discardableResult
    /// Updates the user identifiers with the given identifier and returns the result.
    /// - Parameter other: The identifier to update.
    /// - Returns: The updated identifiers.
    func updateIdentifiers<T: Encodable>(with other: T) throws -> [String: Any]

    @discardableResult
    /// Updates the user attributes with the given attribute and returns the result.
    /// - Parameter other: The attribute to update.
    /// - Returns: The updated attributes.
    func updateAttributes<T: Encodable>(with other: T) throws -> [String: Any]

    /// Updates the user with the given update.
    /// - Parameter userUpdate: The update.
    func update2<A: Encodable, I: Encodable>(with userUpdate: UserUpdate<A, I>) throws

    /// Returns the result of updating the user with the given update.
    /// - Parameter userUpdate: The update.
    /// - Returns: The updated user.
    func update<A: Encodable, I: Encodable>(with userUpdate: UserUpdate<A, I>) throws -> LyticsUser
}
