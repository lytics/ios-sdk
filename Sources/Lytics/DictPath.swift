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
