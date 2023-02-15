//
//  Never+Encodable.swift
//
//  Created by Mathew Gacy on 9/19/22.
//

import Foundation

extension Never: Codable {
    public func encode(to encoder: Encoder) throws {
        // no-op
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.unkeyedContainer()
        throw DecodingError.typeMismatch(
            Never.self,
            DecodingError.Context(
                codingPath: container.codingPath,
                debugDescription: "Unable to instantiate `Never` as it has no values.",
                underlyingError: nil
            )
        )
    }
}
