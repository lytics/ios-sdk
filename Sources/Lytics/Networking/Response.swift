//
//  Response.swift
//
//  Created by Mathew Gacy on 10/3/22.
//

import Foundation

/// Representation of a network response.
struct Response<T> {
    let data: Data
    let httpResponse: HTTPURLResponse

    var statusCode: Int {
        httpResponse.statusCode
    }
}

extension Response {

    /// Creates a new response with the given data an response.
    /// - Parameter tuple: A tuple of the response data and `URLResponse`.
    init(_ tuple: (Data, URLResponse)) throws {
        guard let httpResponse = tuple.1 as? HTTPURLResponse else {
            throw NetworkError.invalidResponse(tuple.1)
        }
        self.data = tuple.0
        self.httpResponse = httpResponse
    }

    /// Validates that the response status code indicates the request was successful.
    ///
    /// Throws an error if the status code indicates the request was not successful.
    func validate() throws -> Self {
        switch statusCode {
        // Success
        case (200..<300): return self
        // Client Error
        case (400..<500): throw NetworkError.clientError(httpResponse)
        // Server Error
        case (500..<600): throw NetworkError.serverError(httpResponse)
        default: throw NetworkError.unknown("Unexpected status code: \(statusCode)")
        }
    }
}

extension Response where T: Decodable {

    /// Returns a model decoded from the response data.
    /// - Parameter decoder: The decoder used to decode the model.
    /// - Returns: The model decoded from the response data.
    func decode(with decoder: JSONDecoder = .init()) throws -> T {
        try decoder.decode(T.self, from: data)
    }
}
