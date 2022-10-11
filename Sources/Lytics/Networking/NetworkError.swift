//
//  NetowrkError.swift
//
//  Created by Mathew Gacy on 9/24/22.
//

import Foundation

/// A network error.
public enum NetworkError: Error {
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
    /// There was a server error.
    case serverError(_ response: HTTPURLResponse)
    /// There was an error decoding the data.
    case decoding(_ error: DecodingError)
    /// Unknown error.
    case unknown(_ message: String)
}

extension NetworkError: LocalizedError {

    /// A description of the error, suitable for debugging.
    public var errorDescription: String? {
        switch self {
        case .malformedRequest:
            return "Malformed Request"
        case .network(let error):
            return "Network Error: \(error.localizedDescription)"
        case .noData:
            return "Missing Data"
        case .invalidResponse(let response):
            return "Unexpected Response Format: \(String(describing: response))"
        case .clientError(let response):
            return "Client Error: \(response.statusCode)"
        case .serverError(let response):
            return "Server Error: \(response.statusCode)"
        case .decoding(let error):
            return "Decoding Error: \(error.userDescription)"
        case .unknown(let message):
            return message
        }
    }
}
