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

    /// Returns a query parameter determining the fields to be returned.
    /// - Parameter fields: The fields to return in the request.
    /// - Returns: The fields query parameter.
    static func fields(_ fields: [String]) -> Self {
        .init(
            name: "fields",
            value: fields.joined(separator: ",")
        )
    }

    /// Returns a filename query parameter.
    /// - Parameter value: An identifier specifying the unique source of an individual event.
    /// - Returns: The filename query parameter.
    static func filename(_ value: String) -> Self {
        .init(name: "filename", value: value)
    }

    /// Returns a query parameter indicating whether Meta Fields should be included in the response.
    /// - Parameter shouldInclude: A Boolean indicating whether the Meta Field should be returned.
    /// - Returns: The meta query parameter.
    static func meta(_ shouldInclude: Bool) -> Self {
        .init(name: "meta", value: String(shouldInclude))
    }

    /// Returns a query parameter indicating whether the segments to which an entity belongs should
    /// be included in the response.
    /// - Parameter shouldInclude: A Boolean indicating whether segments should be returned.
    /// - Returns: The segments query parameter.
    static func segments(_ shouldInclude: Bool) -> Self {
        .init(name: "segments", value: String(shouldInclude))
    }

    /// Returns a timestamp field query parameter.
    /// - Parameter value: The name of the column or field in file that contains event timestamp.
    /// - Returns: The timestamp field query parameter.
    static func timestampField(_ value: String?) -> Self {
        .init(name: "timestamp_field", value: value)
    }
}
