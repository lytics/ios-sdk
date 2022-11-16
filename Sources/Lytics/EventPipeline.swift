//
//  EventPipeline.swift
//
//  Created by Mathew Gacy on 10/1/22.
//

import Foundation

@usableFromInline
/// An event pipeline.
struct EventPipeline: EventPipelineProtocol {

    /// Configurable `EventPipeline` properties.
    struct Configuration: Equatable {

        /// Default stream name to which events will be sent if not explicitly set for an event.
        let defaultStream: String

        /// A Boolean value indicating whether a user must explicitly opt-in to event tracking.
        let requireConsent: Bool

        init(defaultStream: String, requireConsent: Bool) {
            self.defaultStream = defaultStream.isNotEmpty ? defaultStream : Constants.defaultStream
            self.requireConsent = requireConsent
        }
    }

    private let configuration: Configuration
    private let logger: LyticsLogger
    private let sessionDidStart: (Millisecond) -> Bool
    private let eventQueue: EventQueueing
    private let uploader: Uploading
    private let userSettings: UserSettings

    @usableFromInline
    /// A Boolean value indicating whether the user has opted in to event collection.
    var isOptedIn: Bool {
        userSettings.getOptIn()
    }

    init(
        configuration: Configuration,
        logger: LyticsLogger,
        sessionDidStart: @escaping (Millisecond) -> Bool,
        eventQueue: EventQueueing,
        uploader: Uploading,
        userSettings: UserSettings
    ) {
        self.configuration = configuration
        self.logger = logger
        self.sessionDidStart = sessionDidStart
        self.eventQueue = eventQueue
        self.uploader = uploader
        self.userSettings = userSettings
    }

    @usableFromInline
    /// Adds an event to the event pipeline.
    /// - Parameters:
    ///   - stream: The DataType, or "Table" of type of data being uploaded.
    ///   - timestamp: The event timestamp.
    ///   - name: The event name.
    ///   - event: The event.
    func event<E: Encodable>(
        stream: String?,
        timestamp: Millisecond,
        name: String?,
        event: E
    ) async {
        if configuration.requireConsent {
            guard userSettings.getOptIn() else {
                logger.info("User is not opted in; discarding event \(event)")
                return
            }
        }

        await eventQueue.enqueue(
            Payload(
                stream: stream
                    .nonEmpty(default: configuration.defaultStream)
                    .replacingOccurrences(of: " ", with: "_"),
                timestamp: timestamp,
                sessionDidStart: sessionDidStart(timestamp) ? 1 : nil,
                name: name,
                event: event))
    }

    @usableFromInline
    /// Opts the user in to event collection.
    func optIn() {
        userSettings.setOptIn(true)
    }

    @usableFromInline
    /// Opts the user out of event collection.
    func optOut() {
        userSettings.setOptIn(false)
    }

    @usableFromInline
    /// Force flushes the event queue by sending all events in the queue immediately.
    func dispatch() async {
        await eventQueue.flush()
    }
}

extension EventPipeline {
    static func live(
        logger: LyticsLogger,
        apiToken: String,
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
            configuration: Configuration(
                defaultStream: configuration.defaultStream,
                requireConsent: configuration.requireConsent),
            logger: logger,
            sessionDidStart: { timestamp in
                SessionTracker.markInteraction(timestamp) > configuration.sessionDuration.milliseconds
            },
            eventQueue: EventQueue.live(
                logger: logger,
                apiToken: apiToken,
                configuration: configuration,
                upload: { await uploader.upload($0) }),
            uploader: uploader,
            userSettings: .live)
    }
}
