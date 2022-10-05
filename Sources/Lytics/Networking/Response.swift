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
    init(_ tuple: (Data, URLResponse)) throws {
        guard let httpResponse = tuple.1 as? HTTPURLResponse else {
            throw NetworkError.invalidResponse(tuple.1)
        }
        self.data = tuple.0
        self.httpResponse = httpResponse
    }

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
    func decode(with decoder: JSONDecoder = .init()) throws -> T {
        try decoder.decode(T.self, from: data)
    }
}
