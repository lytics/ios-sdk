//
//  RequestCaching.swift
//
//  Created by Mathew Gacy on 10/18/22.
//

import Foundation

/// A type capable of storing requests.
protocol RequestCaching {

    /// Stores a request.
    /// - Parameter request: The requests to store.
    func cache<T: Codable>(_ request: Request<T>) throws

    /// Loads stored requuests.
    /// - Returns: The stored requests.
    func load() throws -> [any RequestProtocol]

    /// Deletes all cached requests.
    func deleteAll() throws
}
