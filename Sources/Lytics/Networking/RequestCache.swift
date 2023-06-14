//
//  RequestCache.swift
//
//  Created by Mathew Gacy on 10/18/22.
//

import Foundation

/// Stores a collection of requests.
struct RequestCache: RequestCaching {
    let decoder: JSONDecoder
    let encoder: JSONEncoder
    let storage: Storage

    init(decoder: JSONDecoder = .init(), encoder: JSONEncoder = .init(), storage: Storage) {
        self.decoder = decoder
        self.encoder = encoder
        self.storage = storage
    }

    /// Caches a collection of wrapped requests.
    /// - Parameter requests: The wrapped requests to cache.
    func cache(_ requests: [any RequestWrapping]) throws {
        guard requests.isNotEmpty else {
            return
        }

        var requestData = try encoder
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
        let decoded: CodableRequestContainer? = try storage.read(decodingWith: decoder)
        return decoded?.requests
    }

    /// Deletes all cached requests.
    func deleteAll() throws {
        try storage.clear()
    }
}

extension RequestCache {
    static func live() throws -> Self {
        .init(
            storage: try .live(
                file: try .requests()))
    }
}
