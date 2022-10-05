//
//  EventPipeline.swift
//
//  Created by Mathew Gacy on 10/1/22.
//

import Foundation

struct EventPipeline {
    let encoder: JSONEncoder
    let logger: LyticsLogger
    let requestBuilder: RequestBuilder
    let requestQueue: RequestQueueing

    init(
        encoder: JSONEncoder = .init(),
        logger: LyticsLogger,
        requestBuilder: RequestBuilder,
        requestQueue: RequestQueueing
    ) {
        self.encoder = encoder
        self.logger = logger
        self.requestBuilder = requestBuilder
        self.requestQueue = requestQueue
    }

    @usableFromInline
    func handle<T: Encodable>(stream: String, event: T) {
    }
}
