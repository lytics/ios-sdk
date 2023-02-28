//
//  JSONDecoder+Utils.swift
//
//  Created by Mathew Gacy on 2/28/23.
//

import Foundation

extension JSONDecoder {

    /// Returns a value decoded from a JSON object.
    /// - Parameter jsonObject: The JSON object to decode.
    /// - Returns: A value of the specified type, if the decoder can parse the data.
    func decodeJSONObject<T: Decodable>(from jsonObject: [String: Any]) throws -> T {
        try decode(T.self, from: try JSONSerialization.data(withJSONObject: jsonObject))
    }
}
