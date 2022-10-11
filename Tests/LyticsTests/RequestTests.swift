//
//  RequestTests.swift
//
//  Created by Mathew Gacy on 10/3/22.
//

@testable import Lytics
import Foundation
import XCTest

final class RequestTests: XCTestCase {
    func testURLRequestConversion() throws {
        let urlString = "https://example.com"
        let body = Data("request body".utf8)

        let parameterName = "parameterName"
        let parameterValue = "parameterValue"

        let headerName = "headerName"
        let headerValue = "headerValue"

        let request = Request<DataUploadResponse>(
            method: .post,
            url: URL(string: urlString)!,
            parameters: [
                QueryParameter(name: parameterName, value: parameterValue)
            ],
            headers: [
                HeaderField(name: headerName, value: headerValue)
            ],
            body: body
        )

        let urlRequest = try request.asURLRequest()

        XCTAssertEqual(urlRequest.httpMethod, "POST")
        XCTAssertEqual(urlRequest.url?.absoluteString, "\(urlString)?\(parameterName)=\(parameterValue)")
        XCTAssertEqual(urlRequest.allHTTPHeaderFields, [headerName: headerValue])
        XCTAssertEqual(urlRequest.httpBody, body)
    }
}
