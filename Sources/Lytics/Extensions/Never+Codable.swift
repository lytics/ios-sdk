//
//  Never+Codable.swift
//
//  Created by Mathew Gacy on 9/19/22.
//

import Foundation

extension Never: Codable {
    public init(from decoder: Decoder) throws {
        fatalError()
    }

    public func encode(to encoder: Encoder) throws {
        // no-op
    }
}
