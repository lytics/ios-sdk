//
//  JSONEncoder+Utils.swift
//
//  Created by Mathew Gacy on 6/6/23.
//

import Foundation

public extension JSONEncoder {

    /// Returns a JSONEncoder that formats its output with sorted keys.
    static var sorted: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return encoder
    }
}
