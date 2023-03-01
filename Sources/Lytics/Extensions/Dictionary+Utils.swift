//
//  Dictionary+Utils.swift
//
//  Created by Mathew Gacy on 9/29/22.
//

import AnyCodable
import Foundation

public extension Dictionary {

    /// Creates a dictionary by deep merging the given dictionary into this dictionary.
    /// - Parameter other: A dictionary to merge.
    /// - Returns: A new dictionary with the combined keys and values of this dictionary and other.
    func deepMerging(_ other: [Key: Value]) -> [Key: Value] {
        var result: [Key: Value] = self
        for (key, value) in other {
            if let dictValue = value as? [Key: Value],
               let existing = result[key] as? [Key: Value],
               let merged = existing.deepMerging(dictValue) as? Value {
                result[key] = merged
            } else {
                result[key] = value
            }
        }
        return result
    }
}

extension Dictionary where Key == AnyCodable, Value == AnyCodable {
    init?<K, V>(_ other: [K: V]?) {
        guard let other else {
            return nil
        }
        self.init(uniqueKeysWithValues: other.map { (AnyCodable($0), AnyCodable($1)) })
    }
}

extension Dictionary where Key == String, Value == Any {

    /// Updates the encoded value at a specified dictionary path by appliying a given transformation.
    /// - Parameters:
    ///   - dictPath: A dictionary path to the encoded value.
    ///   - toValue: A closure that decodes the encoded value.
    ///   - fromValue: A closure that encodes the transformed value.
    ///   - transform: A closure that updates the value at the specified dictionary path.
    mutating func updateValue<V: Codable>(
        at dictPath: DictPath,
        toValue: (Self) throws -> V = JSONDecoder().decodeJSONObject,
        fromValue: (V) throws -> Self = JSONEncoder().encodeJSONObject,
        transform: (inout V?) -> Void
    ) rethrows {
        var value: V?
        if let currentValue = self[dict: dictPath] {
            value = try toValue(currentValue)
        } else {
            value = nil
        }

        // Update with transformed value
        transform(&value)
        if let value {
            self[dictPath: dictPath] = try fromValue(value)
        } else {
            self[dictPath: dictPath] = nil
        }
    }

    /// Updates the primitive value at a specified dictionary path by appliying a given
    /// transformation.
    /// - Parameters:
    ///   - dictPath: A dictionary path to the encoded value.
    ///   - transform: A closure that updates the value at the specified dictionary path.
    mutating func updateValue<V: Primitive>(
        at dictPath: DictPath,
        transform: (inout V?) -> Void
    ) {
        var value = self[dict: dictPath] as? V
        transform(&value)
        self[dictPath: dictPath] = value
    }
}
