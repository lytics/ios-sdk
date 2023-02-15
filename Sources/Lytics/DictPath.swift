//
//  DictPath.swift
//
//  Created by Mathew Gacy on 2/13/23.
//

import Foundation

/// A path to a specific key in a nested dictionary.
public enum DictPath: Codable, Equatable, Hashable {
    indirect case nested(_ key: String, _ remaining: DictPath)
    case tail(_ key: String)
    case none

    public var path: String {
        switch self {
        case let .nested(key, remaining) where remaining.path.isNotEmpty:
            return "\(key).\(remaining.path)"
        case let .nested(key, _):
            return key
        case let .tail(key):
            return key
        case .none:
            return ""
        }
    }
}

extension DictPath {
    init?(keys: [String]) {
        guard keys.isNotEmpty else {
            return nil
        }

        var copy = keys
        let head = copy.removeFirst()
        guard head.isNotEmpty else {
            return nil
        }

        if copy.isEmpty {
            self = .tail(head)
        } else if let remaining = DictPath(keys: copy) {
            self = .nested(head, remaining)
        } else {
            self = .tail(head)
        }
    }

    public init(_ path: String) {
        var keys = path.components(separatedBy: ".")
        let head = keys.removeFirst()

        if head.isEmpty {
            self = .none
        } else if let remaining = DictPath(keys: keys) {
            self = .nested(head, remaining)
        } else {
            self = .tail(head)
        }
    }
}

extension DictPath: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(value)
    }

    public init(unicodeScalarLiteral value: String) {
        self.init(value)
    }

    public init(extendedGraphemeClusterLiteral value: String) {
        self.init(value)
    }
}
