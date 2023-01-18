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

    func testPersonalizationRequest() throws {
        let table = "user"
        let fieldName = "_uid"
        let fieldVal = Mock.uuidString
        let fields: [String]? = ["email", "idfa"]
        let segments = true
        let meta = true

        let sut = RequestBuilder(
            baseURL: Constants.defaultBaseURL,
            apiToken: Mock.apiToken
        )

        let request = sut.entity(
            table: table,
            fieldName: fieldName,
            fieldVal: fieldVal,
            fields: fields,
            segments: segments,
            meta: meta
        )

        XCTAssertEqual(request.method, .get)
        XCTAssertEqual(request.url, URL(string: "https://api.lytics.io/api/entity/\(table)/\(fieldName)/\(fieldVal)")!)
        XCTAssertEqual(
            request.parameters,
            [
                QueryParameter(name: "fields", value: "email,idfa"),
                QueryParameter(name: "segments", value: "\(segments)"),
                QueryParameter(name: "meta", value: "\(meta)")
            ]
        )
        XCTAssertEqual(
            request.headers,
            [
                HeaderField(name: "Content-Type", value: "application/json"),
                HeaderField(name: "Authorization", value: Mock.apiToken)
            ]
        )
        XCTAssertNil(request.body)
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
