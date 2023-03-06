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

    static func valueEquality<T: Equatable>(
        _ value1: [String: Any],
        _ value2: [String: Any],
        at dictPath: DictionaryPath,
        type: T.Type,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        if let value = value2[dictPath: dictPath] {
            XCTAssertEqual(value1[dictPath: dictPath] as! T, value as! T, file: file, line: line)
        } else {
            XCTAssertNil(value1[dictPath: dictPath], file: file, line: line)
        }
    }

    // MARK: - Untyped

    static func attributeEquality(
        _ object: [String: Any],
        expected: [String: Any],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        Assert.valueEquality(object, expected, at: "firstName", type: String.self, file: file, line: line)
        Assert.valueEquality(object, expected, at: "titles", type: [String].self, file: file, line: line)
    }

    static func cartEquality(
        _ object: [String: Any],
        expected: [String: Any],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        Assert.valueEquality(object, expected, at: "orderID", type: String.self, file: file, line: line)
        Assert.valueEquality(object, expected, at: "total", type: Float.self, file: file, line: line)
    }

    static func consentEquality(
        _ object: [String: Any],
        expected: [String: Any],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        Assert.valueEquality(object, expected, at: "document", type: String.self, file: file, line: line)
        Assert.valueEquality(object, expected, at: "timestamp", type: String.self, file: file, line: line)
        Assert.valueEquality(object, expected, at: "consented", type: Bool.self, file: file, line: line)
    }

    static func identifierEquality(
        _ object: [String: Any],
        expected: [String: Any],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        Assert.valueEquality(object, expected, at: "email", type: String.self, file: file, line: line)
        Assert.valueEquality(object, expected, at: "userID", type: Int.self, file: file, line: line)

        if expected["nested"] != nil {
            XCTAssertNotNil(object["nested"])
        } else {
            XCTAssertNil(object["nested"])
        }

        Assert.valueEquality(object, expected, at: "nested.a", type: Int.self, file: file, line: line)
        Assert.valueEquality(object, expected, at: "nested.b", type: String.self, file: file, line: line)
    }

    static func payloadMemberEquality(
        _ object: [String: Any],
        expected: [String: Any],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        Assert.valueEquality(object, expected, at: "name", type: String.self, file: file, line: line)
        Assert.valueEquality(object, expected, at: "_ts", type: Int64.self, file: file, line: line)
        Assert.valueEquality(object, expected, at: "_sesstart", type: Int?.self, file: file, line: line)
    }

    // MARK: - Untyped Events

    static func consentEventEquality(
        _ object: [String: Any],
        expected: [String: Any],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        Assert.payloadMemberEquality(object, expected: expected, file: file, line: line)

        // Identifiers
        let objectIdentifiers = object["identifiers"] as! [String: Any]
        let expectedIdentifiers = expected["identifiers"] as! [String: Any]
        Assert.identifierEquality(objectIdentifiers, expected: expectedIdentifiers, file: file, line: line)

        // Attributes
        let objectAttributes = object["attributes"] as! [String: Any]?
        let expectedAttributes = expected["attributes"] as! [String: Any]?
        if let objectAttributes, let expectedAttributes {
            Assert.attributeEquality(objectAttributes, expected: expectedAttributes, file: file, line: line)
        } else {
            XCTAssert(objectAttributes == nil, file: file, line: line)
            XCTAssert(expectedAttributes == nil, file: file, line: line)
        }

        // Consent
        let objectConsent = object["consent"] as! [String: Any]
        let expectedConsent = expected["consent"] as! [String: Any]
        Assert.consentEquality(objectConsent, expected: expectedConsent, file: file, line: line)
    }

    static func eventEquality(
        _ object: [String: Any],
        expected: [String: Any],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        Assert.payloadMemberEquality(object, expected: expected, file: file, line: line)

        // Identifiers
        let objectIdentifiers = object["identifiers"] as! [String: Any]
        let expectedIdentifiers = expected["identifiers"] as! [String: Any]
        Assert.identifierEquality(objectIdentifiers, expected: expectedIdentifiers, file: file, line: line)

        // Properties
        let objectProperties = object["properties"] as! [String: Any]
        let expectedProperties = expected["properties"] as! [String: Any]
        Assert.cartEquality(objectProperties, expected: expectedProperties, file: file, line: line)
    }

    static func identityEventEquality(
        _ object: [String: Any],
        expected: [String: Any],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        Assert.payloadMemberEquality(object, expected: expected, file: file, line: line)

        // Identifiers
        let objectIdentifiers = object["identifiers"] as! [String: Any]
        let expectedIdentifiers = expected["identifiers"] as! [String: Any]
        Assert.identifierEquality(objectIdentifiers, expected: expectedIdentifiers, file: file, line: line)

        // Attributes
        let objectAttributes = object["attributes"] as! [String: Any]
        let expectedAttributes = expected["attributes"] as! [String: Any]
        Assert.attributeEquality(objectAttributes, expected: expectedAttributes, file: file, line: line)
    }

    // MARK: - Typed

    static func equality(
        _ object: [String: Any],
        with attributes: TestAttributes,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(object["firstName"] as? String, attributes.firstName, file: file, line: line)
        XCTAssertEqual(object["titles"] as? [String], attributes.titles, file: file, line: line)
    }

    static func equality(
        _ object: [String: Any],
        with cart: TestCart,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(object["orderId"] as! String, cart.orderID, file: file, line: line)
        XCTAssertEqual(object["total"] as! Float, cart.total, file: file, line: line)
    }

    static func equality(
        _ object: [String: Any],
        with consent: TestConsent,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(object["document"] as! String, consent.document, file: file, line: line)
        XCTAssertEqual(object["timestamp"] as! String, consent.timestamp, file: file, line: line)
        XCTAssertEqual(object["consented"] as! Bool, consent.consented, file: file, line: line)
    }

    static func equality(
        _ object: [String: Any],
        with identifiers: TestIdentifiers,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(object["email"] as? String, identifiers.email, file: file, line: line)
        XCTAssertEqual(object["userID"] as? Int, identifiers.userID, file: file, line: line)

        // Nested
        let nested = object["nested"] as! [String: Any]
        XCTAssertEqual(nested["a"] as? Int, identifiers.nested?.a, file: file, line: line)
        XCTAssertEqual(nested["b"] as? String, identifiers.nested?.b, file: file, line: line)
    }

    static func equality<E: Encodable>(
        _ object: [String: Any],
        payload: Payload<E>,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(object["name"] as? String, payload.name, file: file, line: line)
        XCTAssertEqual(object["_ts"] as! Int64, payload.timestamp, file: file, line: line)
        XCTAssertEqual(object["_sesstart"] as! Int?, payload.sessionDidStart, file: file, line: line)
    }
}
