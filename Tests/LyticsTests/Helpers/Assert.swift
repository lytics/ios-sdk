//
//  Assert.swift
//
//  Created by Mathew Gacy on 10/21/22.
//

@testable import Lytics
import Foundation
import XCTest

/// Helper for testing equality of untyped dictionaries.
enum Assert {

    // MARK: - Untyped

    static func attributeEquality(_ object: [String: Any], expected: [String: Any]) {
        XCTAssertEqual(object["firstName"] as! String, expected["firstName"] as! String)
        XCTAssertEqual(object["titles"] as! [String], expected["titles"] as! [String])
    }

    static func cartEquality(_ object: [String: Any], expected: [String: Any]) {
        XCTAssertEqual(object["orderID"] as! String, expected["orderID"] as! String)
        XCTAssertEqual(object["total"] as! Float, expected["total"] as! Float)
    }

    static func consentEquality(_ object: [String: Any], expected: [String: Any]) {
        XCTAssertEqual(object["document"] as! String, expected["document"] as! String)
        XCTAssertEqual(object["timestamp"] as! String, expected["timestamp"] as! String)
        XCTAssertEqual(object["consented"] as! Bool, expected["consented"] as! Bool)
    }

    static func identifierEquality(_ object: [String: Any], expected: [String: Any]) {
        XCTAssertEqual(object["email"] as! String, expected["email"] as! String)
        XCTAssertEqual(object["userID"] as! Int, expected["userID"] as! Int)

        // Nested
        let nested = object["nested"] as! [String: Any]
        let expectedNested = expected["nested"] as! [String: Any]
        XCTAssertEqual(nested["a"] as! Int, expectedNested["a"] as! Int)
        XCTAssertEqual(nested["b"] as! String, expectedNested["b"] as! String)
    }

    static func payloadMemberEquality(_ object: [String: Any], expected: [String: Any]) {
        XCTAssertEqual(object["name"] as! String, expected["name"] as! String)
        XCTAssertEqual(object["_ts"] as! Int64, expected["_ts"] as! Int64)
        XCTAssertEqual(object["_sesstart"] as! Int?, expected["_sesstart"] as! Int?)
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
        XCTAssertEqual(object["orderId"] as! String, cart.orderId)
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