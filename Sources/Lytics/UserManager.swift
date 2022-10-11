//
//  UserManager.swift
//
//  Created by Mathew Gacy on 9/29/22.
//

import AnyCodable
import Foundation

actor UserManager: UserManaging {
    private let encoder: JSONEncoder

    /// The user identifiers.
    private(set) var identifiers: [String: Any]

    /// The user attributes.
    private(set) var attributes: [String: Any]

    init(
        encoder: JSONEncoder = .init(),
        identifiers: [String: Any] = [:],
        attributes: [String: Any] = [:]
    ) {
        self.encoder = encoder
        self.identifiers = identifiers
        self.attributes = attributes
    }

    @discardableResult
    /// Updates the user identifiers with the given identifier and returns the result.
    /// - Parameter other: The identifier to update.
    /// - Returns: The updated identifiers.
    func updateIdentifiers<T: Encodable>(with other: T) throws -> [String: Any] {
        identifiers = identifiers.deepMerging(try(convert(other)))
        return identifiers
    }

    @discardableResult
    /// Updates the user attributes with the given attribute and returns the result.
    /// - Parameter other: The attribute to update.
    /// - Returns: The updated attributes.
    func updateAttributes<T: Encodable>(with other: T) throws -> [String: Any] {
        attributes = attributes.deepMerging(try convert(other))
        return attributes
    }

    /// Updates the user with the given update.
    /// - Parameter userUpdate: The update.
    func update2<A: Encodable, I: Encodable>(with userUpdate: UserUpdate<A, I>) throws {
        if let attributesUpdate = userUpdate.attributes {
            try updateAttributes(with: attributesUpdate)
        }

        if let identifiersUpdate = userUpdate.identifiers {
            try updateIdentifiers(with: identifiersUpdate)
        }
    }

    /// Returns the result of updating the user with the given update.
    /// - Parameter userUpdate: The update.
    /// - Returns: The updated user.
    func update<A: Encodable, I: Encodable>(with userUpdate: UserUpdate<A, I>) throws -> LyticsUser {
        let updatedAttributes: [String: Any]
        let updatedIdentifiers: [String: Any]

        if let attributesUpdate = userUpdate.attributes {
            updatedAttributes = try updateAttributes(with: attributesUpdate)
        } else {
            updatedAttributes = attributes
        }

        if let identifiersUpdate = userUpdate.identifiers {
            updatedIdentifiers = try updateIdentifiers(with: identifiersUpdate)
        } else {
            updatedIdentifiers = identifiers
        }

        return LyticsUser(identifiers: updatedIdentifiers, attributes: updatedAttributes)
    }

    private func convert<T: Encodable>(_ value: T) throws -> [String: Any] {
        let data = try encoder.encode(value)
        guard let dictionary = try JSONSerialization.jsonObject(
            with: data,
            options: .allowFragments) as? [String: Any] else {
            throw NSError()
        }
        return dictionary
    }
}
