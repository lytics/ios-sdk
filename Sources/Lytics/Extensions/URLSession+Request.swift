//
//  URLSession+RequestPerforming.swift
//
//  Created by Mathew Gacy on 9/24/22.
//

import Foundation

extension URLSession: RequestPerforming {

    /// Performs a network request and delivers the response asynchronously.
    /// - Parameter request: the request to perform.
    /// - Returns: the request response.
    func perform<T>(_ request: T) async throws -> Response<T.Resp> where T : RequestProtocol {
        try await data(for: request.asURLRequest()) |> Response.init
    }
}
