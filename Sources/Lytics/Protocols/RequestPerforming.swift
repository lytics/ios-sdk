//
//  RequestPerforming.swift
//
//  Created by Mathew Gacy on 10/3/22.
//

import Foundation

/// A class of types capable of performing a netowrk request and returning a resposne.
protocol RequestPerforming {

    /// Downloads the contents of a URL based on the specified request and delivers the response asynchronously.
    /// - Parameter request: The request to perform.
    /// - Returns: An asynchronously-delivered representation of the response.
    func perform<R>(_ request: Request<R>) async throws -> Response<R>
}
