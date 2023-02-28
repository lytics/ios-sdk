//
//  JSONEncoder+Utils.swift
//
//  Created by Mathew Gacy on 2/28/23.
//

import Foundation

extension JSONEncoder {

    /// Returns a JSON-encoded representation of the supplied value.
    /// - Parameter value: The value to encode as JSON.
    /// - Returns: The encoded JSON object.
    func encodeJSONObject<T: Encodable>(_ value: T) throws -> [String: Any] {
        let data = try encode(value)
        guard let dictionary = try JSONSerialization.jsonObject(
            with: data,
            options: .allowFragments
        ) as? [String: Any] else {
            throw EncodingError.invalidValue(
                T.self,
                .init(
                    codingPath: [],
                    debugDescription: "Unable to create a dictionary from \(value)."
                )
            )
        }

        return dictionary
    }
}
