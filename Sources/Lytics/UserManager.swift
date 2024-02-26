//
//  UserManager.swift
//
//  Created by Mathew Gacy on 9/29/22.
//

import AnyCodable
import Foundation

/// An object that manages the current user's identity.
actor UserManager: UserManaging {

    /// Configurable `UserManager` properties.
    struct Configuration: Equatable {

        /// The key that represents the core identifier to be used in api calls.
        var primaryIdentityKey: String = Constants.defaultPrimaryIdentityKey

        /// The key which we use to store the anonymous identifier.
        var anonymousIdentityKey: String = Constants.defaultAnonymousIdentityKey
    }

    private let configuration: Configuration
    private let idfaProvider: () -> String?
    private let idProvider: @Sendable () -> String
    private let encoder: JSONEncoder
    private let storage: UserStorage

    /// The user identifiers.
    private(set) var identifiers: [String: Any] {
        get {
            var identifiers: [String: Any]
            if let currentIdentifiers = storage.identifiers() {
                identifiers = currentIdentifiers
            } else {
                let newIdentifiers = makeAnonymousIdentifiers()
                storage.storeIdentifiers(newIdentifiers)
                identifiers = newIdentifiers
            }

            // Add additional values
            if let idfa = idfaProvider() {
                identifiers[Constants.idfaKey] = idfa
            }

            return identifiers
        }
        set {
            storage.storeIdentifiers(newValue)
        }
    }

    /// The user attributes.
    private(set) var attributes: [String: Any]? {
        get {
            storage.attributes()
        }
        set {
            storage.storeAttributes(newValue)
        }
    }

    /// The current user.
    var user: LyticsUser {
        .init(
            identifiers: identifiers.mapValues(AnyCodable.init(_:)),
            attributes: attributes?.mapValues(AnyCodable.init(_:))
        )
    }

    init(
        configuration: Configuration = .init(),
        encoder: JSONEncoder,
        idfaProvider: @escaping () -> String?,
        idProvider: @escaping @Sendable () -> String = { UUID().uuidString },
        storage: UserStorage
    ) {
        Self.ensure(
            anonymousIdentityKey: configuration.anonymousIdentityKey,
            in: storage,
            idProvider: idProvider
        )

        self.configuration = configuration
        self.encoder = encoder
        self.idfaProvider = idfaProvider
        self.idProvider = idProvider
        self.storage = storage
    }

    /// Updates the user identifiers with the given identifier and returns the result.
    /// - Parameter other: The identifier to update.
    /// - Returns: The updated identifiers.
    @discardableResult
    func updateIdentifiers<T: Encodable>(with other: T) throws -> [String: Any] {
        let updated = identifiers.deepMerging(try (convert(other)))
        identifiers = updated
        return updated
    }

    /// Updates the user attributes with the given attribute and returns the result.
    /// - Parameter other: The attribute to update.
    /// - Returns: The updated attributes.
    @discardableResult
    func updateAttributes<T: Encodable>(with other: T) throws -> [String: Any] {
        let updated: [String: Any]
        if let currentAttributes = attributes {
            updated = currentAttributes.deepMerging(try convert(other))
        } else {
            updated = try convert(other)
        }

        attributes = updated
        return updated
    }

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

    /// Returns the result of updating the user with the given update.
    /// - Parameter userUpdate: The update.
    /// - Returns: The updated user.
    func update<I: Encodable, A: Encodable>(with userUpdate: UserUpdate<I, A>) throws -> LyticsUser {
        let updatedAttributes: [String: Any]?
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

    /// Removes the identifier at the specified dictionary path.
    /// - Parameter path: A dictionary path to the identifier to remove.
    func removeIdentifier(_ path: DictionaryPath) {
        identifiers[path: path] = nil
    }

    /// Removes the attribute at the specified dictionary path.
    /// - Parameter path: A dictionary path to the attribute to remove.
    func removeAttribute(_ path: DictionaryPath) {
        attributes?[path: path] = nil
    }

    /// Clear all stored user information.
    func clear() {
        attributes = nil
        identifiers = makeAnonymousIdentifiers()
    }
}

private extension UserManager {

    /// Stores a value for the anonymous identity key in the given storage if one does not already exist.
    /// - Parameters:
    ///   - anonymousIdentityKey: The key for the anonymous identifier.
    ///   - storage: The user storage.
    ///   - idProvider: The identifier provider.
    static func ensure(anonymousIdentityKey: String, in storage: UserStorage, idProvider: () -> String) {
        var identifiers = storage.identifiers() ?? [:]
        if identifiers[anonymousIdentityKey] == nil {
            identifiers[anonymousIdentityKey] = idProvider()
            storage.storeIdentifiers(identifiers)
        }
    }

    /// Returns a new identifier dictionary with an anonymous identifier.
    func makeAnonymousIdentifiers() -> [String: Any] {
        [configuration.anonymousIdentityKey: idProvider()]
    }

    /// Returns a dictionary representation of a model.
    /// - Parameter value: The model to convert.
    /// - Returns: A dictionary representation of `value`.
    func convert<T: Encodable>(_ value: T) throws -> [String: Any] {
        let data = try encoder.encode(value)
        guard let dictionary = try JSONSerialization.jsonObject(
            with: data,
            options: .allowFragments
        ) as? [String: Any]
        else {
            throw EncodingError.invalidValue(
                T.self,
                .init(
                    codingPath: [],
                    debugDescription: "Unable to create a dictionary from \(value)."
                )
            )
        }
        return dictionary
    }
}

extension UserManager {
    static func live(
        configuration: LyticsConfiguration,
        idfaProvider: @escaping () -> String?
    ) -> UserManager {
        .init(
            configuration: Configuration(
                primaryIdentityKey: configuration.primaryIdentityKey,
                anonymousIdentityKey: configuration.anonymousIdentityKey
            ),
            encoder: JSONEncoder(),
            idfaProvider: idfaProvider,
            idProvider: { UUID().uuidString },
            storage: .live()
        )
    }

    #if DEBUG
        static let mock = UserManager(
            configuration: .init(),
            encoder: JSONEncoder(),
            idfaProvider: { nil },
            storage: .mock()
        )
    #endif
}
