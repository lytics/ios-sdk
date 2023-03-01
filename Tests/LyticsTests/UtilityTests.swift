//
//  UtilityTests.swift
//
//  Created by Mathew Gacy on 10/11/22.
//

import Foundation
@testable import Lytics
import XCTest

final class UtilityTests: XCTestCase {}

// MARK: - Deep-Merging Dictionaries
extension UtilityTests {
    func testSimpleDeepMerging() throws {
        let initial: [String: Any] = [
            "a": "initial",
            "b": "b"
        ]

        let update: [String: Any] = [
            "a": "update",
            "c": 1
        ]

        let updated = initial.deepMerging(update)

        XCTAssertEqual(updated["a"] as? String, "update")
        XCTAssertEqual(updated["b"] as? String, "b")
        XCTAssertEqual(updated["c"] as? Int, 1)
    }

    func testDeepMerging() throws {
        let initial: [String: Any] = [
            "a": 1,
            "b": 2,
            "c": [
                "d": 3
            ]
        ]

        let update: [String: Any] = [
            "b": "4",
            "c": [
                "e": 5
            ]
        ]

        let updated = initial.deepMerging(update)

        XCTAssertEqual(updated["a"] as? Int, 1)
        XCTAssertEqual(updated["b"] as? String, "4")

        let cDictionary = updated["c"] as! [String: Any]

        XCTAssertEqual(cDictionary["d"] as? Int, 3)
        XCTAssertEqual(cDictionary["e"] as? Int, 5)
    }
}

// MARK: - Transforming Dictionary-Encoded Values
extension UtilityTests {
    func testUpdateExistingValue() throws {
        let newValue = "updated"
        let expected: [String: Any] = [
            "email": "someemail@lytics.com",
            "userID": 1_234,
            "nested": [
                "a": 1,
                "b": newValue
            ]
        ]

        var values = User1.anyIdentifiers
        try values.updateValue(at: "nested") { (value: inout Nested?) in
            value?.b = newValue
        }

        Assert.identifierEquality(values, expected: expected)
    }

    func testUpdateAbsentValue() throws {
        var values: [String: Any] = [
            "email": "someemail@lytics.com",
            "userID": 1_234
        ]

        try values.updateValue(at: "nested") { (value: inout Nested?) in
            value = Nested(a: User1.a, b: User1.b)
        }

        Assert.identifierEquality(values, expected: User1.anyIdentifiers)
    }

    func testUpdateRemovingValue() throws {
        var values = User1.anyIdentifiers
        try values.updateValue(at: "nested") { (value: inout Nested?) in
            value = nil
        }

        XCTAssertEqual(values["email"] as! String, "someemail@lytics.com")
        XCTAssertEqual(values["userID"] as! Int, 1_234)
        XCTAssertNil(values["nested"])
    }

    func testUpdatePrimitiveValue() {
        let newValue = "updated"
        let expected: [String: Any] = [
            "email": "someemail@lytics.com",
            "userID": 1_234,
            "nested": [
                "a": 1,
                "b": newValue
            ]
        ]

        var values = User1.anyIdentifiers
        values.updateValue(at: "nested.b") { (value: inout String?) in
            value = newValue
        }

        Assert.identifierEquality(values, expected: expected)
    }

    func testRemovePrimitiveValue() {
        var values = User1.anyIdentifiers
        values.updateValue(at: "nested.b") { (value: inout String?) in
            value = nil
        }

        XCTAssertEqual(values["email"] as! String, "someemail@lytics.com")
        XCTAssertEqual(values["userID"] as! Int, 1_234)
        XCTAssertEqual(values["nested"] as! [String: Int], ["a": 1])
    }
}

// MARK: - Appending JSON Array Data
extension UtilityTests {
    var emptyJSONData: Data {
        Data("""
        []
        """.utf8)
    }

    var lhsJSONData: Data {
        Data("""
        [{"id":1},{"id":2}]
        """.utf8)
    }

    var rhsJSONData: Data {
        Data("""
        [{"id":3},{"id":4}]
        """.utf8)
    }

    var joinedJSONData: Data {
        Data("""
        [{"id":1},{"id":2},{"id":3},{"id":4}]
        """.utf8)
    }

    var invalidJSONData: Data {
        Data("abcd".utf8)
    }

    func testAppendJSONArrayData() throws {
        var initialData = lhsJSONData
        var additionalData = rhsJSONData

        try initialData.append(jsonArray: &additionalData)

        XCTAssertEqual(initialData, joinedJSONData)
    }

    func testAppendToEmptyJSONArrayData() throws {
        var initialData = emptyJSONData
        var additionalData = rhsJSONData

        try initialData.append(jsonArray: &additionalData)

        XCTAssertEqual(initialData, rhsJSONData)
    }

    func testAppendEmptyJSONArrayData() throws {
        var initialData = lhsJSONData
        var additionalData = emptyJSONData

        try initialData.append(jsonArray: &additionalData)

        XCTAssertEqual(initialData, lhsJSONData)
    }

    func testAppendToInvalidArrayThrows() throws {
        var initialData = lhsJSONData
        var additionalData = invalidJSONData
        XCTAssertThrowsError(try initialData.append(jsonArray: &additionalData))
    }

    func testAppendInvalidArrayThrows() {
        var initialData = invalidJSONData
        var additionalData = rhsJSONData
        XCTAssertThrowsError(try initialData.append(jsonArray: &additionalData))
    }
}

// MARK: - Never Codable Conformance
extension UtilityTests {
    struct ImpossibleNever: Codable {
        let value: Never
    }

    struct PossibleNever: Codable {
        var value: Never? = nil
    }

    func testEncodeNeverValue() throws {
        let expectedValue = Data("{}".utf8)

        let actualValue = try JSONEncoder().encode(PossibleNever(value: nil))
        XCTAssertEqual(actualValue, expectedValue)
    }

    func testDecodeNeverValueThrows() {
        let json = Data("""
        {"value":null}
        """.utf8)

        XCTAssertThrowsError(_ = try JSONDecoder().decode(ImpossibleNever.self, from: json))
    }
}
