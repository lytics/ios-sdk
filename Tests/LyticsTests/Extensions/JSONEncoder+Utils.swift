//
//  JSONEncoder+Utils.swift
//
//  Created by Mathew Gacy on 6/6/23.
//

import Foundation

extension JSONEncoder {
    static var sorted: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return encoder
    }
}
