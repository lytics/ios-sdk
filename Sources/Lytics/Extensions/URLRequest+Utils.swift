//
//  URLRequest+Utils.swift
//
//  Created by Mathew Gacy on 9/24/22.
//

import Foundation

extension URLRequest {

    /// Sets a value for the header field.
    /// - Parameter field: the header field to add.
    mutating func setHeader(_ field: HeaderField) {
        setValue(field.value, forHTTPHeaderField: field.name)
    }

    /// Sets the header fields.
    /// - Parameter fields: the header fields to set.
    mutating func setHeaders(_ fields: [HeaderField]) {
        allHTTPHeaderFields = fields.reduce(into: [:]) { $0[$1.name] = $1.value }
    }
}
