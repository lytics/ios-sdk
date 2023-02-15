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
