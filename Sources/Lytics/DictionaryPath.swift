//
//  DictionaryPath.swift
//
//  Created by Mathew Gacy on 2/13/23.
//

import Foundation

/// A path to a specific key in a nested dictionary.
///
/// Use a dict path to access values in a nested dictionary.
///
/// ```swift
/// var dict: [String: Any] = [
///     "outer": [
///         "inner": 5
///     ]
///  ]
///
/// let current = dict[path: "outer.inner"] // 5
/// dict[path: "outer.inner"] = 6 // ["outer": ["inner": 6]]
/// ```
public enum DictionaryPath: Codable, Equatable, Hashable {
    indirect case nested(_ key: String, _ remaining: DictionaryPath)
    case tail(_ key: String)
    case none

    /// The string representation of the dictionary path.
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

public extension DictionaryPath {

    /// Creates a new instance with the given array of keys.
    ///
    /// Example Usage:
    ///
    /// ```swift
    /// let dict: [String: Any] = [
    ///     "outer": [
    ///         "inner": 5
    ///     ]
    ///  ]
    ///
    /// let path = DictionaryPath(keys: ["outer", "inner"])
    /// let value = dict[path: path] // 5
    /// ```
    /// - Parameter keys: The key pahts of the new instance.
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
        } else if let remaining = DictionaryPath(keys: copy) {
            self = .nested(head, remaining)
        } else {
            self = .tail(head)
        }
    }

    /// Creates a new instance with the given key path.
    ///
    /// Example Usage:
    ///
    /// ```swift
    /// let dict: [String: Any] = [
    ///     "outer": [
    ///         "inner": 5
    ///     ]
    ///  ]
    ///
    /// let path = DictionaryPath("outer.inner")
    /// let value = dict[path: path] // 5
    /// ```
    ///
    /// - Parameter path: The value of the new instance.
    init(_ path: String) {
        var keys = path.components(separatedBy: ".")
        let head = keys.removeFirst()

        if head.isEmpty {
            self = .none
        } else if let remaining = DictionaryPath(keys: keys) {
            self = .nested(head, remaining)
        } else {
            self = .tail(head)
        }
    }
}

// MARK: ExpressibleByStringLiteral
extension DictionaryPath: ExpressibleByStringLiteral {

    /// Creates an instance initialized to the given string value.
    /// - Parameter value: The value of the new instance.
    public init(stringLiteral value: String) {
        self.init(value)
    }

    /// Creates an instance initialized to the given value.
    /// - Parameter value: The value of the new instance.
    public init(unicodeScalarLiteral value: String) {
        self.init(value)
    }

    /// Creates an instance initialized to the given value.
    /// - Parameter value: The value of the new instance.
    public init(extendedGraphemeClusterLiteral value: String) {
        self.init(value)
    }
}

// MARK: - Dictionary+DictionaryPath
public extension Dictionary where Key == String {

    /// Accesses the value associated with the given key for reading and writing.
    subscript(path path: DictionaryPath) -> Any? {
        get {
            switch path {
            case .none:
                return nil

            case let .tail(key):
                return self[key]

            case let .nested(key, remainingPath):
                switch self[key] {
                case let nestedDict as [Key: Any]:
                    return nestedDict[path: remainingPath]

                default:
                    return nil
                }
            }
        }
        set {
            switch path {
            case .none:
                return

            case let .tail(key):
                switch newValue {
                case let wrapped as Value:
                    self[key] = wrapped
                default:
                    self[key] = nil
                }

            case let .nested(key, remainingPath):
                switch self[key] {
                case var nestedDict as [Key: Any]:
                    nestedDict[path: remainingPath] = newValue
                    self[key] = nestedDict.isNotEmpty ? nestedDict as? Value : nil

                default:
                    return
                }
            }
        }
    }
}
