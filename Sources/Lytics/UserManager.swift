//
//  UserManager.swift
//
//  Created by Mathew Gacy on 9/29/22.
//

import AnyCodable
import Foundation

/// An object that manages the current user's identity.
@usableFromInline
actor UserManager: UserManaging {
    private let encoder: JSONEncoder

    /// The user identifiers.
    @usableFromInline private(set) var identifiers: [String: Any]

    /// The user attributes.
    @usableFromInline private(set) var attributes: [String: Any]

    /// The current user.
    var user: LyticsUser {
        .init(
            userType: .anonymous,
            identifiers: identifiers.mapValues(AnyCodable.init(_:)),
            attributes: attributes.mapValues(AnyCodable.init(_:)))
    }

    @usableFromInline
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
    @usableFromInline
    /// Updates the user identifiers with the given identifier and returns the result.
    /// - Parameter other: The identifier to update.
    /// - Returns: The updated identifiers.
    func updateIdentifiers<T: Encodable>(with other: T) throws -> [String: Any] {
        identifiers = identifiers.deepMerging(try(convert(other)))
        return identifiers
    }

    @discardableResult
    @usableFromInline
    /// Updates the user attributes with the given attribute and returns the result.
    /// - Parameter other: The attribute to update.
    /// - Returns: The updated attributes.
    func updateAttributes<T: Encodable>(with other: T) throws -> [String: Any] {
        attributes = attributes.deepMerging(try convert(other))
        return attributes
    }

    @usableFromInline
    /// Updates the user with the given update.
    /// - Parameter userUpdate: The update.
    func apply<I: Encodable, A: Encodable>(_ userUpdate: UserUpdate<I, A>) throws {
        if let attributesUpdate = userUpdate.attributes {
            try updateAttributes(with: attributesUpdate)
        }

        if let identifiersUpdate = userUpdate.identifiers {
            try updateIdentifiers(with: identifiersUpdate)
        }
    }

    @usableFromInline
    /// Returns the result of updating the user with the given update.
    /// - Parameter userUpdate: The update.
    /// - Returns: The updated user.
    func update<I: Encodable, A: Encodable>(with userUpdate: UserUpdate<I, A>) throws -> LyticsUser {
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
            options: .allowFragments) as? [String: Any]
        else {
            throw EncodingError.invalidValue(
                T.self,
                .init(
                    codingPath: [],
                    debugDescription: "Unable to creation a dictionary from \(value)."))
        }
        return dictionary
    }
}
