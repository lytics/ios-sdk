//
//  Request.swift
//
//  Created by Mathew Gacy on 9/24/22.
//

import Foundation

/// The HTTP method.
enum HTTPMethod: String, Codable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

/// A representation of a request header field.
struct HeaderField: Codable, Equatable {
    let name: String
    let value: String?
}

/// A representaiton of a URL query parameter.
struct QueryParameter: Codable, Equatable {
    let name: String
    let value: String?
}

/// Type-safe representation of a network request.
struct Request<Response>: Codable, Equatable, URLRequestConvertible {

    /// The HTTP request method.
    let method: HTTPMethod

    /// The URL of the request.
    let url: URL

    /// The URL query parameters of the endpoint's URL.
    var parameters: [QueryParameter]?

    /// The HTTP header fields of the request.
    var headers: [HeaderField]?

    /// The data sent as the message body of a request, such as for an HTTP POST request.
    var body: Data?

    /// Creates a request.
    /// - Parameters:
    ///   - method: The HTTP method for the request.
    ///   - url: The URL for the request.
    ///   - parameters: The query parameters for the request URL.
    ///   - headers: The HTTP header fields for the request.
    ///   - body: The data for the request body.
    init(
        method: HTTPMethod,
        url: URL,
        parameters: [QueryParameter]? = nil,
        headers: [HeaderField]? = nil,
        body: Data? = nil
    ) {
        self.method = method
        self.url = url
        self.parameters = parameters
        self.headers = headers
        self.body = body
    }

    /// Returns a `URLRequest` created from this request.
    /// - Returns: The URL request instance.
    func asURLRequest() throws -> URLRequest {
        var urlRequest: URLRequest
        if let parameters,
           var components = URLComponents(url: url, resolvingAgainstBaseURL: true) {
            components.queryItems = parameters.map { URLQueryItem(name: $0.name, value: $0.value) }

            guard let url = components.url else {
                throw NetworkError.malformedRequest
            }

            urlRequest = URLRequest(url: url)
        } else {
            urlRequest = URLRequest(url: url)
        }

        urlRequest.httpMethod = method.rawValue

        if let headers {
            urlRequest.setHeaders(headers)
        }

        // body *needs* to be the last property that we set, because of this bug: https://bugs.swift.org/browse/SR-6687
        urlRequest.httpBody = body

        return urlRequest
    }
}

// MARK: RequestProtocol
extension Request: RequestProtocol where Response: Decodable {
    typealias Resp = Response
}
