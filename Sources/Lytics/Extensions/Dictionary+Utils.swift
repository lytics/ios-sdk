//
//  Dictionary+Utils.swift
//
//  Created by Mathew Gacy on 9/29/22.
//

import Foundation

extension Dictionary {

    /// Creates a dictionary by deep merging the given dictionary into this dictionary.
    /// - Parameter other: A dictionary to merge.
    /// - Returns: A new dictionary with the combined keys and values of this dictionary and other.
    public func deepMerging(_ other: [Key: Value]) -> [Key: Value] {
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
