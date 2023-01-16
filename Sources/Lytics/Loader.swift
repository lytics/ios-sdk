//
//  Loader.swift
//
//  Created by Mathew Gacy on 1/15/23.
//

import Foundation

struct Loader {
    var entity: (String, String) async throws -> Entity
}

extension Loader {
    static func live(
        configuration: LyticsConfiguration,
        requestBuilder: RequestBuilder,
        requestPerformer: RequestPerforming
    ) -> Self {
        .init(
            entity: { field, value in
                let request = requestBuilder.entity(
                    table: configuration.defaultTable,
                    fieldName: field,
                    fieldVal: value
                )

                let perform: @Sendable () async throws -> Entity = {
                    try await requestPerformer
                        .perform(request)
                        .validate()
                        .decode()
                }

                if configuration.maxLoadRetryAttempts > 0 {
                    return try await Task.retrying(
                        maxRetryCount: configuration.maxLoadRetryAttempts,
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
