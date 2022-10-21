//
//  RequestCache.swift
//
//  Created by Mathew Gacy on 10/18/22.
//

import Foundation

/// Stores a collection of requests.
struct RequestCache: RequestCaching {

    /// Stores a request.
    /// - Parameter request: The requests to store.
    func cache<T: Codable>(_ request: Request<T>) throws {
        // ...
    }

    /// Loads stored requuests.
    /// - Returns: The stored requests.
    func load() throws -> [any RequestProtocol] {
        // ...
        return []
    }

    /// Deletes all cached requests.
    func deleteAll() throws {
        // ...
    }
}

extension RequestCache {
    static var live: Self {
        .init()
    }
}
