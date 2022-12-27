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
