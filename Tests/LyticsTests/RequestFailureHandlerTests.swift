//
//  RequestFailureHandler.swift
//
//  Created by Mathew Gacy on 10/21/22.
//

import Foundation
@testable import Lytics
import XCTest

final class RequestFailureHandlerTests: XCTestCase {
    let maxRetryCount: Int = 3
    let initialDelay: TimeInterval = 10
    let delayMultiplier: Double = 1.0

    func testRetryStrategy() {
        let sut = RequestFailureHandler.live(
            maxRetryCount: maxRetryCount,
            initialDelay: initialDelay,
            delayMultiplier: delayMultiplier
        )

        let error = NetworkError.invalidResponse(nil)

        var retryCount = 0

        // Initial Retry
        let initialRetry = sut.strategy(for: error, retryCount: retryCount)
        XCTAssertEqual(initialRetry, .retry(initialDelay))
        retryCount += 1

        // Second Retry
        let secondRetry = sut.strategy(for: error, retryCount: retryCount)
        XCTAssertEqual(secondRetry, .retry(initialDelay * 2))
        retryCount += 1

        // Final retry
        let finalRetry = sut.strategy(for: error, retryCount: retryCount)
        XCTAssertEqual(finalRetry, .retry(initialDelay * 4))
        retryCount += 1

        // Store
        let finalStrategy = sut.strategy(for: error, retryCount: retryCount)
        XCTAssertEqual(finalStrategy, .store)
    }

    func testDiscardStrategy() {
        let sut = RequestFailureHandler.live(
            maxRetryCount: maxRetryCount,
            initialDelay: initialDelay,
            delayMultiplier: delayMultiplier
        )

        var caughtError: Error!
        do {
            _ = try JSONDecoder().decode(
                Bool.self,
                from: Data("abc".utf8)
            )
        } catch {
            caughtError = error
        }

        let strategy = sut.strategy(for: caughtError, retryCount: 0)
        switch strategy {
        case .discard:
            return
        case .retry, .store:
            XCTFail("Unexpected strategy: \(strategy)")
        }
    }
}
