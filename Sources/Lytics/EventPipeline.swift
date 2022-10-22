//
//  EventPipeline.swift
//
//  Created by Mathew Gacy on 10/1/22.
//

import Foundation

@usableFromInline
/// An event pipeline.
struct EventPipeline {
    let logger: LyticsLogger
    let sessionDidStart: (Millisecond) -> Bool
    let eventQueue: EventQueueing
    let uploader: Uploading

    init(
        logger: LyticsLogger,
        sessionDidStart: @escaping (Millisecond) -> Bool,
        eventQueue: EventQueueing,
        uploader: Uploading
    ) {
        self.logger = logger
        self.sessionDidStart = sessionDidStart
        self.eventQueue = eventQueue
        self.uploader = uploader
    }

    @usableFromInline
    func event<E: Encodable>(
        stream: String,
        timestamp: Millisecond,
        name: String?,
        event: E
    ) async {
        await eventQueue.enqueue(
            Payload(
                stream: stream,
                timestamp: timestamp,
                sessionDidStart: sessionDidStart(timestamp) ? 1 : nil,
                event: event))
    }
}

extension EventPipeline {
    static func live(
        logger: LyticsLogger,
        configuration: LyticsConfiguration
    ) -> Self {
        let requestCache = RequestCache.live
        let uploader = Uploader.live(
            logger: logger,
            cache: requestCache,
            maxRetryCount: configuration.maxRetryCount)

        return EventPipeline(
            logger: logger,
            sessionDidStart: { timestamp in
                false
            },
            eventQueue: EventQueue.live(
                logger: logger,
                configuration: configuration,
                upload: { await uploader.upload($0) }),
            uploader: uploader)
    }
}
