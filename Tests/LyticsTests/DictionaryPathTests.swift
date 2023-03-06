//
//  DictionaryPathTests.swift
//
//  Created by Mathew Gacy on 2/13/23.
//

import Foundation
@testable import Lytics
import XCTest

final class DictionaryPathTests: XCTestCase {
    let dict: [String: Any] = [
        "countries": [
            "japan": [
                "capital": [
                    "name": "tokyo",
                    "lat": "35.6895",
                    "lon": "139.6917"
                ],
                "language": "japanese"
            ]
        ],
        "airports": [
            "germany": ["FRA", "MUC", "HAM", "TXL"]
        ]
    ]

    func testGetNone() {
        let none = DictionaryPath.none
        let nestedNone = DictionaryPath.nested("countries", none)

        XCTAssertNil(dict[path: none])
        XCTAssertNil(dict[path: nestedNone])
    }

    func testGetNested() {
        let actual = dict[path: "countries.japan.capital.name"] as? String
        XCTAssertEqual(actual, "tokyo")
    }

    func testGetAbsentKey() {
        XCTAssertNil(dict[path: "countries.germany"])
    }

    func testSetNone() {
        let none = DictionaryPath("")
        let nestedNone = DictionaryPath.nested("nested", none)

        let nested = ["key": "value"]
        var dict: [String: Any] = [
            "nested": nested,
            "other": 5
        ]

        dict[path: none] = "updated"
        var actual = dict["nested"] as? [String: String]
        XCTAssertEqual(actual, nested)

        dict[path: nestedNone] = "updated"
        actual = dict["nested"] as? [String: String]
        XCTAssertEqual(actual, nested)
    }

    func testSetNested() {
        var dict = self.dict

        dict[path: "countries.japan.capital.name"] = "other"

        let countries = dict["countries"] as! [String: Any]
        let japan = countries["japan"] as! [String: Any]
        let capital = japan["capital"] as! [String: String]

        let expected = [
            "name": "other",
            "lat": "35.6895",
            "lon": "139.6917"
        ]

        XCTAssertEqual(capital, expected)
    }

    func testSetNilRemovesEmptyDict() {
        var dict: [String: Any] = [
            "a": [
                "b": [
                    "c": "d"
                ]
            ]
        ]

        dict[path: "a.b.c"] = nil
        XCTAssert(dict.isEmpty)
    }

    func testPath() {
        let none = DictionaryPath.none
        XCTAssertEqual(none.path, "")

        let root = "root"

        let tail = DictionaryPath.tail(root)
        XCTAssertEqual(tail.path, root)

        let nested = DictionaryPath.nested(root, .tail("tail"))
        XCTAssertEqual(nested.path, "root.tail")

        let noTail = DictionaryPath.nested(root, .none)
        XCTAssertEqual(noTail.path, root)
    }

    func testStringLiteral() {
        let actual: DictionaryPath = "countries.japan.capital.name"

        let name = DictionaryPath.tail("name")
        let capital = DictionaryPath.nested("capital", name)
        let japan = DictionaryPath.nested("japan", capital)
        let expected = DictionaryPath.nested("countries", japan)

        XCTAssertEqual(actual, expected)
    }
}
