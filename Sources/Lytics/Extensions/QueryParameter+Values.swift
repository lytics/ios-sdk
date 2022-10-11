//
//  QueryParameter+Values.swift
//
//  Created by Mathew Gacy on 9/24/22.
//

import Foundation

extension QueryParameter {

    /// Returns a dryrun query parameter.
    /// - Parameter value: A Boolean indicating whether an event should be processed.
    /// - Returns: The dryrun query parameter.
    static func dryrun(_ value: Bool?) -> Self {
        .init(name: "dryrun", value: value.flatMap(String.init))
    }

    /// Returns a filename query parameter.
    /// - Parameter value: An identifier specifying the unique source of an individual event.
    /// - Returns: The filename query parameter.
    static func filename(_ value: String) -> Self {
        .init(name: "filename", value: value)
    }

    /// Returns a timestamp field query parameter.
    /// - Parameter value: The name of the column or field in file that contains event timestamp.
    /// - Returns: The timestamp field query parameter.
    static func timestampField(_ value: String?) -> Self {
        .init(name: "timestamp_field", value: value)
    }
}
