//
//  NetowrkError.swift
//
//  Created by Mathew Gacy on 9/24/22.
//

import Foundation

/// A network error.
enum NetworkError: Error {
    /// Not a valid request.
    case malformedRequest
    /// Capture any underlying Error from the URLSession API.
    case network(_ error: Error)
    /// No data returned from server.
    case noData
    /// The server response was in an unexpected format.
    case invalidResponse(_ response: URLResponse?)
    /// There was a client error: 400-499.
    case clientError(_ response: HTTPURLResponse)
    /// There was a server error: 500 - 599.
    case serverError(_ response: HTTPURLResponse)
    /// There was an error decoding the data.
    case decoding(_ error: DecodingError)
    /// Unknown error.
    case unknown(_ message: String)
}

// MARK: LocalizedError
extension NetworkError: LocalizedError {

    /// A description of the error, suitable for debugging.
    var errorDescription: String? {
        switch self {
        case .malformedRequest:
            return "Malformed Request"
        case let .network(error):
            return "Network Error: \(error.localizedDescription)"
        case .noData:
            return "Missing Data"
        case let .invalidResponse(response):
            return "Unexpected Response Format: \(String(describing: response))"
        case let .clientError(response):
            return "Client Error: \(response.statusCode)"
        case let .serverError(response):
            return "Server Error: \(response.statusCode)"
        case let .decoding(error):
            return "Decoding Error: \(error.userDescription)"
        case let .unknown(message):
            return message
        }
    }
}
