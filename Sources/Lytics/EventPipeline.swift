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

    init(
        logger: LyticsLogger,
        eventQueue: EventQueueing
    ) {
        self.logger = logger
        self.eventQueue = eventQueue
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

    @usableFromInline
    func event<P: Encodable>(_ screenEvent: ScreenEvent<P>) async {
        await eventQueue.enqueue(screenEvent)
    }
}

extension EventPipeline {
    static func live(
        logger: LyticsLogger,
        configuration: LyticsConfiguration
    ) -> Self {
        EventPipeline(
            logger: logger,
            eventQueue: EventQueue.live(
                logger: logger,
                configuration: configuration))
    }
}
