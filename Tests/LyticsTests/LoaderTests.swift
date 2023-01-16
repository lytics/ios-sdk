//
//  LoaderTests.swift
//
//  Created by Mathew Gacy on 1/15/23.
//

@testable import Lytics
import XCTest

final class LoaderTests: XCTestCase {
    let baseURLString = "https://example.com"
    let defaultTable = "test"
    let field = "test_field"
    let value = "test_value"

    var identifier: EntityIdentifier {
        .init(
            name: field,
            value: value
        )
    }

    func testEntity() async throws {
        let expectedEntity = Mock.entity
        let entityResponse = Response<Entity>(
            data: try JSONEncoder().encode(expectedEntity),
            httpResponse: Mock.httpResponse()
        )

        var performedRequest: Request<Entity>!
        let requestExpectation = expectation(description: "Request performed")
        let requestPerformer = RequestPerformerMock<Entity> { request in
            performedRequest = request
            defer { requestExpectation.fulfill() }
            return entityResponse
        }

        let configuration = LyticsConfiguration(
            maxRetryCount: 0,
            defaultTable: defaultTable
        )

        let requestBuilder = RequestBuilder(
            baseURL: URL(string: baseURLString)!,
            apiToken: Mock.apiToken
        )

        let sut = Loader.live(
            configuration: configuration,
            requestBuilder: requestBuilder,
            requestPerformer: requestPerformer
        )

        let actualEntity = try await sut.entity(identifier)

        await waitForExpectations(timeout: 0.1)

        XCTAssertEqual(actualEntity, expectedEntity)
        XCTAssertEqual(
            performedRequest.url.absoluteString,
            "\(baseURLString)/api/entity/\(defaultTable)/\(field)/\(value)"
        )
    }

    func testEntityUsesRetrying() async throws {
        let maxRetryCount = 1

        let counter = Counter()
        let requestPerformer = RequestPerformerMock<Entity> { _ in
            Task {
                _ = await counter.increment()
            }
            throw TestError(message: "Expected")
        }

        let configuration = LyticsConfiguration(
            maxRetryCount: maxRetryCount,
            defaultTable: defaultTable
        )

        let requestBuilder = RequestBuilder(
            baseURL: URL(string: baseURLString)!,
            apiToken: Mock.apiToken
        )

        let sut = Loader.live(
            configuration: configuration,
            requestBuilder: requestBuilder,
            requestPerformer: requestPerformer
        )

        let errorExpectation = expectation(description: "Entity threw error")
        do {
            _ = try await sut.entity(identifier)
        } catch {
            errorExpectation.fulfill()
        }

        await waitForExpectations(timeout: 0.1)
        let requestCount = await counter.count
        XCTAssertEqual(requestCount, maxRetryCount + 1)
    }
}
