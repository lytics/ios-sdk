//
//  RequestBuilderTests.swift
//
//  Created by Mathew Gacy on 11/16/22.
//

@testable import Lytics
import XCTest

final class RequestBuilderTests: XCTestCase {
    func testDataUploadRequest() throws {
        let requestData = Data("Hello, world!".utf8)

        let sut = RequestBuilder(
            baseURL: Constants.defaultBaseURL,
            apiToken: Mock.apiToken
        )

        let request = sut.dataUpload(
            stream: Stream.one,
            data: requestData
        )

        XCTAssertEqual(request.method, .post)
        XCTAssertEqual(request.url, URL(string: "https://api.lytics.io/collect/json/\(Stream.one)")!)
        XCTAssertNil(request.parameters)
        XCTAssertEqual(
            request.headers,
            [
                HeaderField(name: "Content-Type", value: "application/json"),
                HeaderField(name: "Authorization", value: Mock.apiToken)
            ]
        )
        XCTAssertEqual(request.body, requestData)
    }

    func testCustomBaseURLRequest() throws {
        var configuration = LyticsConfiguration()
        configuration.baseURL = URL(string: "https://mycustomdomain.com")!
        configuration.apiPath = "/c/tacos"

        let sut = RequestBuilder(
            baseURL: configuration.apiURL,
            apiToken: Mock.apiToken
        )

        let request = sut.dataUpload(
            stream: Stream.one,
            data: Data()
        )

        XCTAssertEqual(request.url, URL(string: "https://mycustomdomain.com/c/tacos/collect/json/\(Stream.one)")!)
    }
}
