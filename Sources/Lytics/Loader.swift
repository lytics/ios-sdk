//
//  Loader.swift
//
//  Created by Mathew Gacy on 1/15/23.
//

import Foundation

struct Loader {
    typealias Table = String

    var entity: (Table, EntityIdentifier) async throws -> Entity
}

extension Loader {
    static func live(
        configuration: LyticsConfiguration,
        requestBuilder: RequestBuilder,
        requestPerformer: RequestPerforming
    ) -> Self {
        .init(
            entity: { table, identifier in
                let request = requestBuilder.entity(
                    table: table,
                    fieldName: identifier.name,
                    fieldVal: identifier.value
                )

                let perform: @Sendable () async throws -> Entity = {
                    try await requestPerformer
                        .perform(request)
                        .validate()
                        .decode()
                }

                if configuration.maxRetryCount > 0 {
                    return try await Task.retrying(
                        maxRetryCount: configuration.maxRetryCount,
                        operation: perform
                    )
                    .value
                } else {
                    return try await perform()
                }
            }
        )
    }
}
