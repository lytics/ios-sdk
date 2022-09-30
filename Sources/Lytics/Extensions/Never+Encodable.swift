//
//  Never+Encodable.swift
//
//  Created by Mathew Gacy on 9/19/22.
//

import Foundation

extension Never: Encodable {
    public func encode(to encoder: Encoder) throws {
        // no-op
    }
}
