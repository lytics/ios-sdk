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
    let eventQueue: EventQueueing
    let uploader: Uploading

    init(
        logger: LyticsLogger,
        eventQueue: EventQueueing,
        uploader: Uploading
    ) {
        self.logger = logger
        self.eventQueue = eventQueue
        self.uploader = uploader
    }

    @usableFromInline
    func event<P: Encodable>(_ event: Event<P>) async {
        await eventQueue.enqueue(event)
    }

    @usableFromInline
    func event<I: Encodable, A: Encodable>(_ identityEvent: IdentityEvent<I, A>) async {
        await eventQueue.enqueue(identityEvent)
    }

    @usableFromInline
    func event<C: Encodable>(_ consentEvent: ConsentEvent<C>) async {
        await eventQueue.enqueue(consentEvent)
    }
}

extension EventPipeline {
    static func live(
        logger: LyticsLogger,
        configuration: LyticsConfiguration
    ) -> Self {
        let uploader = Uploader.live(logger: logger)

        return EventPipeline(
            logger: logger,
            eventQueue: EventQueue.live(
                logger: logger,
                configuration: configuration,
                upload: { await uploader.upload($0) }),
            uploader: uploader)
    }
}
