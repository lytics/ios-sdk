//
//  TaskUtilityTests.swift
//
//  Created by Mathew Gacy on 1/15/23.
//

@testable import Lytics
import XCTest

final class TaskUtilityTests: XCTestCase {
    func testRetryingRetries() async throws {
        let maxRetryCount = 3
        let expectedResult = "done"

        let completionExpectation = expectation(description: "Operation succeeded")
        let counter = Counter()
        let operation: @Sendable () async throws -> String = {
            if await counter.increment() <= maxRetryCount {
                throw TestError(message: "Expected")
            }
            completionExpectation.fulfill()
            return expectedResult
        }

        let result = try await Task.retrying(
            maxRetryCount: maxRetryCount,
            operation: operation
        ).value

        await waitForExpectations(timeout: 0.1)
        XCTAssertEqual(result, expectedResult)

        let operationCount = await counter.count
        XCTAssertEqual(operationCount, maxRetryCount + 1)
    }

    func testRetryingShouldRetry() async {
        let maxRetryCount = 3
        let errorMessage = "Expected"

        let counter = Counter()
        let operation: @Sendable () async throws -> String = {
            _ = await counter.increment()
            throw TestError(message: errorMessage)
        }

        let handlerExpectation = expectation(description: "Handler called")
        let shouldRetry: @Sendable (Error) -> Bool = { _ in
            defer { handlerExpectation.fulfill() }
            return false
        }

        let errorExpectation = expectation(description: "Error thrown")
        var caughtError: TestError!
        do {
            _ = try await Task.retrying(
                maxRetryCount: maxRetryCount,
                shouldRetry: shouldRetry,
                operation: operation
            ).value
        } catch let testError as TestError {
            caughtError = testError
            errorExpectation.fulfill()
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }

        await waitForExpectations(timeout: 0.1)

        XCTAssertEqual(caughtError, TestError(message: errorMessage))
        let operationCount = await counter.count
        XCTAssertEqual(operationCount, 1)
    }
}
