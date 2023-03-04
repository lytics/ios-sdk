//
//  UserManagerMock.swift
//
//  Created by Mathew Gacy on 1/24/23.
//

import Foundation
@testable import Lytics
import XCTest

actor UserManagerMock<Identifiers: Encodable, Attributes: Encodable>: UserManaging {
    var onApply: (UserUpdate<Identifiers, Attributes>) throws -> Void
    var onClear: () -> Void
    var onUpdate: (UserUpdate<Identifiers, Attributes>) throws -> LyticsUser
    var onUpdateAttributes: (Attributes) throws -> [String: Any]
    var onUpdateIdentifiers: (Identifiers) throws -> [String: Any]
    var onRemoveIdentifier: (DictPath) -> Void
    var onRemoveAttribute: (DictPath) -> Void

    init(
        onApply: @escaping (UserUpdate<Identifiers, Attributes>) throws -> Void = { _ in XCTFail("UserManagerMock.onApply") },
        onClear: @escaping () -> Void = { XCTFail("UserManagerMock.onClear") },
        onUpdate: @escaping (UserUpdate<Identifiers, Attributes>) throws -> LyticsUser = { _ in XCTFail("UserManagerMock.onUpdate"); return .init() },
        onUpdateAttributes: @escaping (Attributes) throws -> [String: Any] = { _ in XCTFail("UserManagerMock.onUpdateAttributes"); return [:] },
        onUpdateIdentifiers: @escaping (Identifiers) throws -> [String: Any] = { _ in XCTFail("UserManagerMock.onUpdateIdentifiers"); return [:] },
        onRemoveIdentifier: @escaping (DictPath) -> Void = { _ in XCTFail("UserManagerMock.onRemoveIdentifier") },
        onRemoveAttribute: @escaping (DictPath) -> Void = { _ in XCTFail("UserManagerMock.onRemoveAttribute") },
        identifiers: [String: Any] = [:],
        attributes: [String: Any]? = nil,
        user: LyticsUser = .init()
    ) {
        self.onApply = onApply
        self.onClear = onClear
        self.onUpdate = onUpdate
        self.onUpdateAttributes = onUpdateAttributes
        self.onUpdateIdentifiers = onUpdateIdentifiers
        self.onRemoveIdentifier = onRemoveIdentifier
        self.onRemoveAttribute = onRemoveAttribute
        self.identifiers = identifiers
        self.attributes = attributes
        self.user = user
    }

    // MARK: UserManaging

    var identifiers: [String: Any]
    var attributes: [String: Any]?
    var user: LyticsUser

    func updateIdentifiers<T: Encodable>(with other: T) throws -> [String: Any] {
        let identifiers = other as! Identifiers
        return try onUpdateIdentifiers(identifiers)
    }

    func updateAttributes<T: Encodable>(with other: T) throws -> [String: Any] {
        let attributes = other as! Attributes
        return try onUpdateAttributes(attributes)
    }

    func apply<I: Encodable, A: Encodable>(_ userUpdate: UserUpdate<I, A>) throws {
        let update = userUpdate as! UserUpdate<Identifiers, Attributes>
        try onApply(update)
    }

    func update<I: Encodable, A: Encodable>(with userUpdate: UserUpdate<I, A>) throws -> LyticsUser {
        let update = userUpdate as! UserUpdate<Identifiers, Attributes>
        return try onUpdate(update)
    }

    func removeIdentifier(_ dictPath: DictPath) {
        onRemoveIdentifier(dictPath)
    }

    func removeAttribute(_ dictPath: DictPath) {
        onRemoveAttribute(dictPath)
    }

    func clear() {
        onClear()
    }
}
