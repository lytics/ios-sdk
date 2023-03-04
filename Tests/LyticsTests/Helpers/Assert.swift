//
//  Assert.swift
//
//  Created by Mathew Gacy on 10/21/22.
//

import Foundation
@testable import Lytics
import XCTest

/// Helper for testing equality of untyped dictionaries.
enum Assert {

    // MARK: - Helpers

    static func valueEquality<T: Equatable>(_ value1: [String: Any], _ value2: [String: Any], at dictPath: DictPath, type: T.Type) {
        if let value = value2[dictPath: dictPath] {
            XCTAssertEqual(value1[dictPath: dictPath] as! T, value as! T)
        } else {
            XCTAssertNil(value1[dictPath: dictPath])
        }
    }

    // MARK: - Untyped

    static func attributeEquality(_ object: [String: Any], expected: [String: Any]) {
        Assert.valueEquality(object, expected, at: "firstName", type: String.self)
        Assert.valueEquality(object, expected, at: "titles", type: [String].self)
    }

    static func cartEquality(_ object: [String: Any], expected: [String: Any]) {
        Assert.valueEquality(object, expected, at: "orderID", type: String.self)
        Assert.valueEquality(object, expected, at: "total", type: Float.self)
    }

    static func consentEquality(_ object: [String: Any], expected: [String: Any]) {
        Assert.valueEquality(object, expected, at: "document", type: String.self)
        Assert.valueEquality(object, expected, at: "timestamp", type: String.self)
        Assert.valueEquality(object, expected, at: "consented", type: Bool.self)
    }

    static func identifierEquality(_ object: [String: Any], expected: [String: Any]) {
        Assert.valueEquality(object, expected, at: "email", type: String.self)
        Assert.valueEquality(object, expected, at: "userID", type: Int.self)

        if expected["nested"] != nil {
            XCTAssertNotNil(object["nested"])
        } else {
            XCTAssertNil(object["nested"])
        }

        Assert.valueEquality(object, expected, at: "nested.a", type: Int.self)
        Assert.valueEquality(object, expected, at: "nested.b", type: String.self)
    }

    static func payloadMemberEquality(_ object: [String: Any], expected: [String: Any]) {
        Assert.valueEquality(object, expected, at: "name", type: String.self)
        Assert.valueEquality(object, expected, at: "_ts", type: Int64.self)
        Assert.valueEquality(object, expected, at: "_sesstart", type: Int?.self)
    }

    // MARK: - Untyped Events

    static func consentEventEquality(_ object: [String: Any], expected: [String: Any]) {
        Assert.payloadMemberEquality(object, expected: expected)

        // Identifiers
        let objectIdentifiers = object["identifiers"] as! [String: Any]
        let expectedIdentifiers = expected["identifiers"] as! [String: Any]
        Assert.identifierEquality(objectIdentifiers, expected: expectedIdentifiers)

        // Attributes
        let objectAttributes = object["attributes"] as! [String: Any]?
        let expectedAttributes = expected["attributes"] as! [String: Any]?
        if let objectAttributes, let expectedAttributes {
            Assert.attributeEquality(objectAttributes, expected: expectedAttributes)
        } else {
            XCTAssert(objectAttributes == nil)
            XCTAssert(expectedAttributes == nil)
        }

        // Consent
        let objectConsent = object["consent"] as! [String: Any]
        let expectedConsent = expected["consent"] as! [String: Any]
        Assert.consentEquality(objectConsent, expected: expectedConsent)
    }

    static func eventEquality(_ object: [String: Any], expected: [String: Any]) {
        Assert.payloadMemberEquality(object, expected: expected)

        // Identifiers
        let objectIdentifiers = object["identifiers"] as! [String: Any]
        let expectedIdentifiers = expected["identifiers"] as! [String: Any]
        Assert.identifierEquality(objectIdentifiers, expected: expectedIdentifiers)

        // Properties
        let objectProperties = object["properties"] as! [String: Any]
        let expectedProperties = expected["properties"] as! [String: Any]
        Assert.cartEquality(objectProperties, expected: expectedProperties)
    }

    static func identityEventEquality(_ object: [String: Any], expected: [String: Any]) {
        Assert.payloadMemberEquality(object, expected: expected)

        // Identifiers
        let objectIdentifiers = object["identifiers"] as! [String: Any]
        let expectedIdentifiers = expected["identifiers"] as! [String: Any]
        Assert.identifierEquality(objectIdentifiers, expected: expectedIdentifiers)

        // Attributes
        let objectAttributes = object["attributes"] as! [String: Any]
        let expectedAttributes = expected["attributes"] as! [String: Any]
        Assert.attributeEquality(objectAttributes, expected: expectedAttributes)
    }

    // MARK: - Typed

    static func equality(_ object: [String: Any], with attributes: TestAttributes) {
        XCTAssertEqual(object["firstName"] as? String, attributes.firstName)
        XCTAssertEqual(object["titles"] as? [String], attributes.titles)
    }

    static func equality(_ object: [String: Any], with cart: TestCart) {
        XCTAssertEqual(object["orderId"] as! String, cart.orderID)
        XCTAssertEqual(object["total"] as! Float, cart.total)
    }

    static func equality(_ object: [String: Any], with consent: TestConsent) {
        XCTAssertEqual(object["document"] as! String, consent.document)
        XCTAssertEqual(object["timestamp"] as! String, consent.timestamp)
        XCTAssertEqual(object["consented"] as! Bool, consent.consented)
    }

    static func equality(_ object: [String: Any], with identifiers: TestIdentifiers) {
        XCTAssertEqual(object["email"] as? String, identifiers.email)
        XCTAssertEqual(object["userID"] as? Int, identifiers.userID)

        // Nested
        let nested = object["nested"] as! [String: Any]
        XCTAssertEqual(nested["a"] as? Int, identifiers.nested?.a)
        XCTAssertEqual(nested["b"] as? String, identifiers.nested?.b)
    }

    static func equality<E: Encodable>(_ object: [String: Any], payload: Payload<E>) {
        XCTAssertEqual(object["name"] as? String, payload.name)
        XCTAssertEqual(object["_ts"] as! Int64, payload.timestamp)
        XCTAssertEqual(object["_sesstart"] as! Int?, payload.sessionDidStart)
    }
}
