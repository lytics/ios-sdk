//
//  RequestCaching.swift
//
//  Created by Mathew Gacy on 10/18/22.
//

import Foundation

/// A type capable of storing requests.
protocol RequestCaching {

    /// Caches a collection of wrapped requests.
    /// - Parameter requests: The wrapped requests to cache.
    func cache(_ requests: [any RequestWrapping]) throws

    /// Loads cached requuests.
    /// - Returns: The cached requests.
    func load() throws -> [any RequestWrapping]?

    /// Deletes all cached requests.
    func deleteAll() throws
}
