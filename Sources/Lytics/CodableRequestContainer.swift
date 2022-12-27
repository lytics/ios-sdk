//
//  CodableRequestContainer.swift
//
//  Created by Mathew Gacy on 10/22/22.
//

import Foundation

struct CodableRequestContainer: Codable {
    var requests: [any RequestWrapping]

    init(requests: [any RequestWrapping]) {
        self.requests = requests
    }

    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        self.requests = []

        let jsonDecoder = JSONDecoder()
        while !container.isAtEnd {
            let typeName = try container.decode(String.self)
            guard let type = _typeByName(typeName) as? any Decodable.Type else {
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "\(typeName) is not decodable."
                )
            }
            let encodedValue = try container.decode(String.self)

            if let value = try jsonDecoder.decode(type, from: Data(encodedValue.utf8)) as? (any RequestWrapping) {
                requests.insert(value, at: 0)
            }
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        for event in requests.reversed() {
            func open<A: Encodable>(_: A.Type) throws -> Data {
                try JSONEncoder().encode(event as! A)
            }

            try container.encode(_mangledTypeName(type(of: event)))

            let string = try String(
                decoding: _openExistential(type(of: event), do: open),
                as: UTF8.self
            )
            try container.encode(string)
        }
    }
}
