//
//  QueryParameter+Values.swift
//
//  Created by Mathew Gacy on 9/24/22.
//

import Foundation

extension QueryParameter {

    // TODO: add docstring
    static func dryrun(_ value: Bool?) -> Self {
        .init(name: "dryrun", value: value.flatMap(String.init))
    }

    /// Just for record-keeping in our event stream.
    static func filename(_ value: String) -> Self {
        .init(name: "filename", value: value)
    }

    /// The name of the column or field in file that contains event timestamp.
    static func timestampField(_ value: String?) -> Self {
        .init(name: "timestamp_field", value: value)
    }
}
