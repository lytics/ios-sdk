//
//  UserManager.swift
//
//  Created by Mathew Gacy on 9/29/22.
//

import AnyCodable
import Foundation

@usableFromInline
/// An object that manages the current user's identity.
actor UserManager: UserManaging {

    /// Configurable `UserManager` properties.
    struct Configuration: Equatable {

        /// The key that represents the core identifier to be used in api calls.
        public var primaryIdentityKey: String = "_uid"

        /// The key which we use to store the anonymous identifier.
        public var anonymousIdentityKey: String = "_uid"
    }

    private let configuration: Configuration
    private let idProvider: () -> String
    private let encoder: JSONEncoder
    private let storage: UserStorage

    /// The user identifiers.
    @usableFromInline private(set) var identifiers: [String: Any]

    /// The user attributes.
    @usableFromInline private(set) var attributes: [String: Any]

    /// The current user.
    @usableFromInline var user: LyticsUser {
        .init(
            identifiers: identifiers.mapValues(AnyCodable.init(_:)),
            attributes: attributes.mapValues(AnyCodable.init(_:)))
    }

    init(
        configuration: Configuration = .init(),
        encoder: JSONEncoder,
        idProvider: @escaping () -> String = { UUID().uuidString },
        storage: UserStorage
    ) {
        self.configuration = configuration
        self.encoder = encoder
        self.idProvider = idProvider
        self.storage = storage
        self.attributes = storage.attributes() ?? [:]

        if let identifiers = storage.identifiers() {
            self.identifiers = identifiers
        } else {
            let identifiers = [configuration.anonymousIdentityKey: idProvider()]
            storage.storeIdentifiers(identifiers)
            self.identifiers = identifiers
        }
    }

    @discardableResult
    @usableFromInline
    /// Updates the user identifiers with the given identifier and returns the result.
    /// - Parameter other: The identifier to update.
    /// - Returns: The updated identifiers.
    func updateIdentifiers<T: Encodable>(with other: T) throws -> [String: Any] {
        identifiers = identifiers.deepMerging(try(convert(other)))
        storage.storeIdentifiers(identifiers)
        return identifiers
    }

    @discardableResult
    @usableFromInline
    /// Updates the user attributes with the given attribute and returns the result.
    /// - Parameter other: The attribute to update.
    /// - Returns: The updated attributes.
    func updateAttributes<T: Encodable>(with other: T) throws -> [String: Any] {
        attributes = attributes.deepMerging(try convert(other))
        storage.storeAttributes(attributes)
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

    @usableFromInline
    /// Clear all stored user information.
    func clear() {
        attributes = [:]
        storage.storeAttributes(attributes)

        identifiers = [configuration.anonymousIdentityKey: idProvider()]
        storage.storeIdentifiers(identifiers)
    }
}

private extension UserManager {

    /// Returns a dictionary representation of a model.
    /// - Parameter value: The model to convert.
    /// - Returns: A dictionary representation of `value`.
    func convert<T: Encodable>(_ value: T) throws -> [String: Any] {
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

extension UserManager {
    @usableFromInline
    static func live(configuration: LyticsConfiguration) -> UserManager {
        .init(
            configuration: Configuration(
                primaryIdentityKey: configuration.primaryIdentityKey,
                anonymousIdentityKey: configuration.anonymousIdentityKey),
            encoder: JSONEncoder(),
            idProvider: { UUID().uuidString },
            storage: .live)
    }

    #if DEBUG
    static let mock = UserManager(
        configuration: .init(),
        encoder: JSONEncoder(),
        storage: .mock())
    #endif
}
