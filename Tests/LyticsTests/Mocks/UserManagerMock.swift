//
//  UserManagerMock.swift
//
//  Created by Mathew Gacy on 1/24/23.
//

import Foundation
@testable import Lytics
import XCTest

actor UserManagerMock<Identifiers: Encodable, Attributes: Encodable>: UserManaging {
    var onApply: (UserUpdate<Identifiers, Attributes>) -> Void
    var onClear: () -> Void
    var onUpdate: (UserUpdate<Identifiers, Attributes>) -> LyticsUser
    var onUpdateAttributes: (Attributes) -> [String: Any]
    var onUpdateIdentifiers: (Identifiers) -> [String: Any]

    init(
        onApply: @escaping (UserUpdate<Identifiers, Attributes>) -> Void = { _ in XCTFail("UserManagerMock.onApply") },
        onClear: @escaping () -> Void = { XCTFail("UserManagerMock.onClear") },
        onUpdate: @escaping (UserUpdate<Identifiers, Attributes>) -> LyticsUser = { _ in XCTFail("UserManagerMock.onUpdate"); return .init() },
        onUpdateAttributes: @escaping (Attributes) -> [String: Any] = { _ in XCTFail("UserManagerMock.onUpdateAttributes"); return [:] },
        onUpdateIdentifiers: @escaping (Identifiers) -> [String: Any] = { _ in XCTFail("UserManagerMock.onUpdateIdentifiers"); return [:] },
        identifiers: [String: Any] = [:],
        attributes: [String: Any]? = nil,
        user: LyticsUser = .init()
    ) {
        self.onApply = onApply
        self.onClear = onClear
        self.onUpdate = onUpdate
        self.onUpdateAttributes = onUpdateAttributes
        self.onUpdateIdentifiers = onUpdateIdentifiers
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
        return onUpdateIdentifiers(identifiers)
    }

    func updateAttributes<T: Encodable>(with other: T) throws -> [String: Any] {
        let attributes = other as! Attributes
        return onUpdateAttributes(attributes)
    }

    func apply<I: Encodable, A: Encodable>(_ userUpdate: UserUpdate<I, A>) throws {
        let update = userUpdate as! UserUpdate<Identifiers, Attributes>
        onApply(update)
    }

    func update<I: Encodable, A: Encodable>(with userUpdate: UserUpdate<I, A>) throws -> LyticsUser {
        let update = userUpdate as! UserUpdate<Identifiers, Attributes>
        return onUpdate(update)
    }

    func clear() {
        onClear()
    }
}
