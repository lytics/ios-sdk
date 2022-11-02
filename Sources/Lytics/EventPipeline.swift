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
    let userSettings: UserSettings

    var isOptedIn: Bool {
        userSettings.getOptIn()
    }

    init(
        logger: LyticsLogger,
        sessionDidStart: @escaping (Millisecond) -> Bool,
        eventQueue: EventQueueing,
        uploader: Uploading,
        userSettings: UserSettings
    ) {
        self.logger = logger
        self.sessionDidStart = sessionDidStart
        self.eventQueue = eventQueue
        self.uploader = uploader
        self.userSettings = userSettings
    }

    @usableFromInline
    func event<E: Encodable>(
        stream: String,
        timestamp: Millisecond,
        name: String?,
        event: E
    ) async {
        guard userSettings.getOptIn() else {
            logger.info("User is not opted in; discarding event \(event)")
            return
        }

        await eventQueue.enqueue(
            Payload(
                stream: stream,
                timestamp: timestamp,
                sessionDidStart: sessionDidStart(timestamp) ? 1 : nil,
                name: name,
                event: event))
    }

    @usableFromInline
    func optIn() {
        userSettings.setOptIn(true)
    }

    @usableFromInline
    func optOut() {
        userSettings.setOptIn(false)
    }

    func dispatch() async {
        await eventQueue.flush()
    }
}

extension EventPipeline {
    static func live(
        logger: LyticsLogger,
        configuration: LyticsConfiguration
    ) -> Self {
        var requestCache: RequestCache?
        do {
            requestCache = try RequestCache.live()
        } catch {
            logger.error("Unable to create RequestCache: \(error)")
        }

        let uploader = Uploader.live(
            logger: logger,
            cache: requestCache,
            maxRetryCount: configuration.maxRetryCount)

        return EventPipeline(
            logger: logger,
            sessionDidStart: { timestamp in
                SessionTracker.markInteraction(timestamp) > configuration.sessionDuration.milliseconds
            },
            eventQueue: EventQueue.live(
                logger: logger,
                configuration: configuration,
                upload: { await uploader.upload($0) }),
            uploader: uploader,
            userSettings: .live)
    }
}
