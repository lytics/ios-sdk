//
//  DataUploadRequestBuilder.swift
//
//  Created by Mathew Gacy on 10/17/22.
//

import Foundation

struct DataUploadRequestBuilder {
    var requests: ([String: [any StreamEvent]]) throws -> [Request<DataUploadResponse>]
}

extension DataUploadRequestBuilder {
    static func live(apiKey: String) -> Self {
        .init(requests: { _ in [] })
    }
}
