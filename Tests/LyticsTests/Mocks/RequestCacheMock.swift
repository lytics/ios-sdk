//
//  RequestCacheMock.swift
//
//  Created by Mathew Gacy on 1/2/23.
//

import Foundation
@testable import Lytics

final class RequestCacheMock: RequestCaching {
    var onCache: ([any RequestWrapping]) throws -> Void
    var onLoad: () throws -> [any RequestWrapping]?
    var onDelete: () throws -> Void

    init(
        onCache: @escaping ([any RequestWrapping]) throws -> Void = { _ in },
        onLoad: @escaping () throws -> [any RequestWrapping]? = { nil },
        onDelete: @escaping () throws -> Void = {}
    ) {
        self.onCache = onCache
        self.onLoad = onLoad
        self.onDelete = onDelete
    }

    func cache(_ requests: [any RequestWrapping]) throws {
        try onCache(requests)
    }

    func load() throws -> [any RequestWrapping]? {
        try onLoad()
    }

    func deleteAll() throws {
        try onDelete()
    }
}
