//
//  LyticsLoggerTests.swift
//
//  Created by Mathew Gacy on 12/6/22.
//

@testable import Lytics
import os.log
import XCTest

final class LyticsLoggerTests: XCTestCase {

    func testLogLevelRespected() {
        let logExpectation = expectation(description: "Logger logged")
        logExpectation.isInverted = true

        var sut = LyticsLogger(logLevel: nil) { _, _, _, _, _ in
            logExpectation.fulfill()
        }

        sut.error("Log error")
        sut.info("Log info")
        sut.debug("Log debug")

        sut.logLevel = .error
        sut.info("Log info")
        sut.debug("Log debug")

        sut.logLevel = .info
        sut.debug("Log debug")

        waitForExpectations(timeout: 0.1)
    }

    func testLogLevelPassed() {
        var logType: OSLogType?
        let sut = LyticsLogger(logLevel: .debug) { type, _, _, _, _ in
            logType = type
        }

        sut.error("Log error")
        XCTAssertEqual(logType, .error)

        sut.info("Log info")
        XCTAssertEqual(logType, .info)

        sut.debug("Log debug")
        XCTAssertEqual(logType, .debug)
    }

    func testMessagePassed() {
        var loggedMessage: String?
        let sut = LyticsLogger(logLevel: .debug) { _, message, _, _, _ in
            loggedMessage = message()
        }

        let value = 5
        sut.debug("Logged message: \(value)")
        XCTAssertEqual(loggedMessage, "Logged message: 5")
    }
}
