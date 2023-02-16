//
//  DictPathTests.swift
//
//  Created by Mathew Gacy on 2/13/23.
//

@testable import Lytics
import Foundation
import XCTest

final class DictPathTests: XCTestCase {
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
        let none = DictPath.none
        let nestedNone = DictPath.nested("countries", none)

        XCTAssertNil(dict[dictPath: none])
        XCTAssertNil(dict[dictPath: nestedNone])
    }

    func testGetNested() {
        let actual = dict[dictPath: "countries.japan.capital.name"] as? String
        XCTAssertEqual(actual, "tokyo")
    }

    func testGetAbsentKey() {
        XCTAssertNil(dict[dictPath: "countries.germany"])
    }

    func testSetNone() {
        let none = DictPath("")
        let nestedNone = DictPath.nested("nested", none)

        let nested: [String: String] = ["key": "value"]
        var dict: [String: Any] = [
            "nested": nested,
            "other": 5
        ]

        dict[dictPath: none] = "updated"
        var actual = dict["nested"] as? [String: String]
        XCTAssertEqual(actual, nested)

        dict[dictPath: nestedNone] = "updated"
        actual = dict["nested"] as? [String: String]
        XCTAssertEqual(actual, nested)
    }

    func testSetNested() {
        var dict = self.dict

        dict[dictPath: "countries.japan.capital.name"] = "other"

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

        dict[dictPath: "a.b.c"] = nil
        XCTAssert(dict.isEmpty)
    }

    func testPath() {
        let none = DictPath.none
        XCTAssertEqual(none.path, "")

        let root = "root"

        let tail = DictPath.tail(root)
        XCTAssertEqual(tail.path, root)

        let nested = DictPath.nested(root, .tail("tail"))
        XCTAssertEqual(nested.path, "root.tail")

        let noTail = DictPath.nested(root, .none)
        XCTAssertEqual(noTail.path, root)
    }

    func testStringLiteral() {
        let actual: DictPath = "countries.japan.capital.name"

        let name = DictPath.tail("name")
        let capital = DictPath.nested("capital", name)
        let japan = DictPath.nested("japan", capital)
        let expected = DictPath.nested("countries", japan)

        XCTAssertEqual(actual, expected)
    }
}
