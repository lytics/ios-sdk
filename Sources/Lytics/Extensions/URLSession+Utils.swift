//
//  URLSession+Utils.swift
//
//  Created by Mathew Gacy on 9/24/22.
//

import Foundation

// MARK: - URLSession + RequestPerforming
extension URLSession: RequestPerforming {

    /// Downloads the contents of a URL based on the specified request and delivers the response asynchronously.
    /// - Parameter request: The request to perform.
    /// - Returns: An asynchronously-delivered representation of the response.
    func perform<R>(_ request: Request<R>) async throws -> Response<R> {
        try await data(for: request.asURLRequest()) |> Response.init
    }
}

extension URLSession {
    static var live: URLSession = {
        let configuration = URLSessionConfiguration.default
        return URLSession(configuration: configuration)
    }()
}
