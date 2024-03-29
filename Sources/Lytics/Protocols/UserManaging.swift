//
//  UserManaging.swift
//
//  Created by Mathew Gacy on 10/11/22.
//

import AnyCodable
import Foundation

/// A type that manages user identifiers and attributes.
protocol UserManaging: Actor {

    /// The user identifiers.
    var identifiers: [String: Any] { get }

    /// The user attributes.
    var attributes: [String: Any]? { get }

    /// The current user.
    var user: LyticsUser { get }

    /// Updates the user identifiers with the given identifier and returns the result.
    /// - Parameter other: The identifier to update.
    /// - Returns: The updated identifiers.
    @discardableResult
    func updateIdentifiers<T: Encodable>(with other: T) throws -> [String: Any]

    /// Updates the user attributes with the given attribute and returns the result.
    /// - Parameter other: The attribute to update.
    /// - Returns: The updated attributes.
    @discardableResult
    func updateAttributes<T: Encodable>(with other: T) throws -> [String: Any]

    /// Updates the user with the given update.
    /// - Parameter userUpdate: The update.
    func apply<A: Encodable, I: Encodable>(_ userUpdate: UserUpdate<A, I>) throws

    /// Returns the result of updating the user with the given update.
    /// - Parameter userUpdate: The update.
    /// - Returns: The updated user.
    func update<A: Encodable, I: Encodable>(with userUpdate: UserUpdate<A, I>) throws -> LyticsUser

    /// Removes the identifier at the specified dictionary path.
    /// - Parameter path: A dictionary path to the identifier to remove.
    func removeIdentifier(_ path: DictionaryPath)

    /// Removes the attribute at the specified dictionary path.
    /// - Parameter path: A dictionary path to the attribute to remove.
    func removeAttribute(_ path: DictionaryPath)

    /// Clear all stored user information.
    func clear()
}
