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
}
