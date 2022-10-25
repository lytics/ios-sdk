//
//  RequestCache.swift
//
//  Created by Mathew Gacy on 10/18/22.
//

import Foundation

/// Stores a collection of requests.
struct RequestCache: RequestCaching {
    let storage: Storage

    init(storage: Storage) throws {
        self.storage = storage
    }

    /// Caches a collection of wrapped requests.
    /// - Parameter requests: The wrapped requests to cache.
    func cache(_ requests: [any RequestWrapping]) throws {
        guard requests.isNotEmpty else {
            return
        }

        var requestData = try JSONEncoder()
            .encode(
                CodableRequestContainer(requests: requests))

        let currentData = try storage.read()
        if var currentData, currentData.count > 2 {
            try currentData.append(jsonArray: &requestData)
            try storage.write(currentData)
        } else {
            try storage.write(requestData)
        }
    }

    /// Loads cached requuests.
    /// - Returns: The cached requests.
    func load() throws -> [any RequestWrapping]? {
        guard let data = try storage.read() else {
            return nil
        }

        let decoded = try JSONDecoder()
            .decode(CodableRequestContainer.self, from: data)
        return decoded.requests
    }

    /// Deletes all cached requests.
    func deleteAll() throws {
        try storage.clear()
    }
}

extension RequestCache {
    static func live() throws -> Self {
        try .init(
            storage: try .live(
                file: try .requests()))
    }
}
