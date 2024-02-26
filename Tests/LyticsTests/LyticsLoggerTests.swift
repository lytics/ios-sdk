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

    func testErrorLevelPassed() {
        let logExpectation = expectation(description: "Logger logged")
        let sut = LyticsLogger(logLevel: .debug) { type, _, _, _, _ in
            XCTAssertEqual(type, .error)
            logExpectation.fulfill()
        }

        sut.error("Log error")
        waitForExpectations(timeout: 0.1)
    }

    func testInfoLevelPassed() {
        let logExpectation = expectation(description: "Logger logged")
        let sut = LyticsLogger(logLevel: .debug) { type, _, _, _, _ in
            XCTAssertEqual(type, .info)
            logExpectation.fulfill()
        }

        sut.info("Log info")
        waitForExpectations(timeout: 0.1)
    }

    func testDebugLevelPassed() {
        let logExpectation = expectation(description: "Logger logged")
        let sut = LyticsLogger(logLevel: .debug) { type, _, _, _, _ in
            XCTAssertEqual(type, .debug)
            logExpectation.fulfill()
        }

        sut.debug("Log debug")
        waitForExpectations(timeout: 0.1)
    }

    func testMessagePassed() {
        let logExpectation = expectation(description: "Logger logged")
        let sut = LyticsLogger(logLevel: .debug) { _, message, _, _, _ in
            XCTAssertEqual(message(), "Logged message: 5")
            logExpectation.fulfill()
        }

        let value = 5
        sut.debug("Logged message: \(value)")
        waitForExpectations(timeout: 0.1)
    }
}
