//
//  UtilityTests.swift
//
//  Created by Mathew Gacy on 10/11/22.
//

@testable import Lytics
import Foundation
import XCTest

final class UtilityTests: XCTestCase {
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
