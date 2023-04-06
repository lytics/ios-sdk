//
//  UploaderTests.swift
//
//  Created by Mathew Gacy on 12/28/22.
//

import Foundation
@testable import Lytics
import XCTest

final class UploaderTests: XCTestCase {
    typealias PendingRequest<R: Codable> = Uploader.PendingRequest<R>

    let completionDelay: UInt64 = 1_000_000

    func testUpload() async throws {
        let requestExpectation = expectation(description: "Request performed")
        var performedRequest: Request<DataUploadResponse>!
        let requestPerformer = RequestPerformerMock { request in
            defer { requestExpectation.fulfill() }
            performedRequest = request

            return Response(
                data: try! JSONEncoder().encode(Mock.dataUploadResponse),
                httpResponse: Mock.httpResponse(200)
            )
        }

        let sut = Uploader(
            logger: .mock,
            requestPerformer: requestPerformer,
            errorHandler: .failing,
            cache: RequestCacheMock(onLoad: { nil })
        )

        let initialRequestCount = await sut.pendingRequestCount
        XCTAssertEqual(initialRequestCount, 0)

        let requests: [Request<DataUploadResponse>] = [Mock.request]
        await sut.upload(requests)

        let requestCount = await sut.pendingRequestCount
        XCTAssertEqual(requestCount, requests.count)

        await fulfillment(of: [requestExpectation], timeout: 0.5)
        XCTAssertEqual(performedRequest, requests.first!)

        // Delay to give uploader time to remove request
        try await Task.sleep(nanoseconds: completionDelay)
        let finalRequestCount = await sut.pendingRequestCount
        XCTAssertEqual(finalRequestCount, 0)
    }

    func testUploadWhenShouldNotSend() async throws {
        let cacheExpectation = expectation(description: "Request cached")
        var cachedRequests: [any RequestWrapping]!
        let cache = RequestCacheMock(
            onCache: { wrappedRequests in
                cachedRequests = wrappedRequests
                cacheExpectation.fulfill()
            }
        )

        let sut = Uploader(
            logger: .mock,
            requestPerformer: RequestPerformerMock<DataUploadResponse>.failing,
            errorHandler: .failing,
            cache: cache
        )

        // Ensure uploader caches subsequent requests
        await sut.storeRequests()

        let request = Mock.request
        await sut.upload([request])
        await fulfillment(of: [cacheExpectation], timeout: 0.5)

        let cachedRequest = cachedRequests.first! as! PendingRequest<DataUploadResponse>
        XCTAssertEqual(cachedRequest.request, request)
    }

    func testStoreRequests() async throws {
        let requestExpectation = expectation(description: "Request performed")
        let requestPerformer = RequestPerformerMock<DataUploadResponse> { _ in
            defer { requestExpectation.fulfill() }
            throw NetworkError.serverError(Mock.httpResponse(500))
        }

        let cache = RequestCacheMock()

        let sut = Uploader(
            logger: .mock,
            requestPerformer: requestPerformer,
            errorHandler: .init(strategy: { _, _ in .retry(10) }),
            cache: cache
        )

        // Upload attempt
        let request = Mock.request
        await sut.upload([request])
        await fulfillment(of: [], timeout: 0.1)

        let cacheExpectation = expectation(description: "Request cached")
        var cachedRequests: [any RequestWrapping]!
        cache.onCache = { wrappedRequests in
            cachedRequests = wrappedRequests
            cacheExpectation.fulfill()
        }

        await sut.storeRequests()
        await fulfillment(of: [requestExpectation, cacheExpectation], timeout: 0.1)

        let cachedRequest = cachedRequests.first! as! PendingRequest<DataUploadResponse>
        XCTAssertEqual(cachedRequest.request, request)
    }

    func testLoadRequests() async throws {
        let requestExpectation = expectation(description: "Request performed")
        var performedRequest: Request<DataUploadResponse>!
        let requestPerformer = RequestPerformerMock { request in
            defer { requestExpectation.fulfill() }
            performedRequest = request

            return Response(
                data: try! JSONEncoder().encode(Mock.dataUploadResponse),
                httpResponse: Mock.httpResponse(200)
            )
        }

        let storedRequest = PendingRequest(
            id: Mock.uuid,
            request: Mock.request
        )

        let loadExpectation = expectation(description: "Storage was loaded")
        let clearExpectation = expectation(description: "Storage was cleared")
        var hasLoadedRequest = false
        let cache = RequestCacheMock(
            onLoad: {
                // Handle attempt to send cached requests after success
                if hasLoadedRequest {
                    return nil
                } else {
                    defer { loadExpectation.fulfill() }
                    hasLoadedRequest = true
                    return [storedRequest]
                }
            },
            onDelete: {
                clearExpectation.fulfill()
            }
        )

        let sut = Uploader(
            logger: .mock,
            requestPerformer: requestPerformer,
            errorHandler: .failing,
            cache: cache
        )

        try await sut.loadRequests()

        await fulfillment(of: [requestExpectation, loadExpectation, clearExpectation], timeout: 0.5)
        XCTAssertEqual(performedRequest, Mock.request)
    }

    func testErrorHandling() async throws {
        var requestExpectation: XCTestExpectation!
        let requestPerformer = RequestPerformerMock<DataUploadResponse> { _ in
            defer { requestExpectation.fulfill() }
            throw NetworkError.serverError(
                Mock.httpResponse(500))
        }

        var failureStrategyExpectation: XCTestExpectation!
        var failureStrategy: RequestFailureHandler.Strategy!
        let errorHandler = RequestFailureHandler { _, _ in
            defer { failureStrategyExpectation.fulfill() }
            return failureStrategy
        }

        let cache = RequestCacheMock()

        let sut = Uploader(
            logger: .mock,
            requestPerformer: requestPerformer,
            errorHandler: errorHandler,
            cache: cache
        )

        // Initial request - retry on failure
        requestExpectation = expectation(description: "Initial request sent")
        failureStrategyExpectation = expectation(description: "Retry")
        let retryDelay: TimeInterval = 0.2
        failureStrategy = .retry(retryDelay)

        let request = Mock.request
        await sut.upload([request])

        // Wait for initial attempt
        await fulfillment(of: [requestExpectation, failureStrategyExpectation], timeout: 0.1)

        // Retried request - store on failure
        requestExpectation = expectation(description: "Request was retried")
        failureStrategyExpectation = expectation(description: "Store")
        failureStrategy = .store

        var cacheExpectation = expectation(description: "Request cached")
        var cachedRequests: [any RequestWrapping]!
        cache.onCache = { wrappedRequests in
            cachedRequests = wrappedRequests
            cacheExpectation.fulfill()
        }

        // Wait for retried attempt and storage
        await fulfillment(of: [requestExpectation, failureStrategyExpectation, cacheExpectation], timeout: retryDelay * 2)
        let cachedRequest = cachedRequests.first! as! PendingRequest<DataUploadResponse>
        XCTAssertEqual(cachedRequest.request, request)

        // New reguest - discard on failure
        requestExpectation = expectation(description: "Request with discarded failure")
        failureStrategyExpectation = expectation(description: "Discard")
        failureStrategy = .discard("")

        cacheExpectation = expectation(description: "Request unexpectedly cached")
        cacheExpectation.isInverted = true

        await sut.upload([Mock.request])
        await fulfillment(of: [requestExpectation, failureStrategyExpectation, cacheExpectation], timeout: 0.5)
    }

    func testRequestsLoadedAfterSuccess() async throws {
        let requestExpectation = expectation(description: "Request performed")
        let requestPerformer = RequestPerformerMock<DataUploadResponse> { _ in
            defer { requestExpectation.fulfill() }

            return Response(
                data: try! JSONEncoder().encode(Mock.dataUploadResponse),
                httpResponse: Mock.httpResponse(200)
            )
        }

        let loadExpectation = expectation(description: "Stored requests were loaded.")
        let cache = RequestCacheMock(
            onLoad: {
                loadExpectation.fulfill()
                return nil
            }
        )

        let sut = Uploader(
            logger: .mock,
            requestPerformer: requestPerformer,
            errorHandler: .failing,
            cache: cache
        )

        await sut.upload([Mock.request])
        await fulfillment(of: [requestExpectation, loadExpectation], timeout: 0.1)
    }
}
