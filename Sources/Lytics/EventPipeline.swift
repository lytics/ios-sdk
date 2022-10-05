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
        Task(priority: .background) {
            do {
                try Task.checkCancellation()

                let data = try encoder.encode(event)
                let request = requestBuilder.dataUpload(stream: stream, data: data)

                try Task.checkCancellation()

                await requestQueue.enqueue(request)
            } catch is CancellationError {
                logger.debug("Task for \(stream) was canceled")
            } catch {
                logger.error(error.localizedDescription)
            }
        }
    }
}
