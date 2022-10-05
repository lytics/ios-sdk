//
//  Lytics.swift
//
//  Created by Mathew Gacy on 9/12/22.
//

import Foundation

public final class Lytics {

    /// The shared instance.
    public static let shared: Lytics = {
        let instance = Lytics()
        // ...
        return instance
    }()

    internal var logger: LyticsLogger = .live

    internal var eventPipeline: EventPipeline!

    internal private(set) var defaultStream: String = ""

    /// A Boolean value indicating whether this instance has been started.
    public private(set) var hasStarted: Bool = false

    /// A Boolean value indicating whether the user has opted into event collection.
    public var isOptedIn: Bool {
        false
    }

    /// A Boolean value indicating whether IDFA is enabled.
    public var isIDFAEnabled: Bool {
        false
    }

    /// The current Lytics user.
    public private(set) var user: LyticsUser

    internal init(
        user: LyticsUser = .init()
    ) {
        self.user = user
    }

    /// Configure this Lytics SDK instance.
    /// - Parameter configuration: A closure enabling mutation of the configuration.
    public func start(_ configure: (inout LyticsConfiguration) -> Void) {
        guard !hasStarted else {
            logger.error("Lytics instance has already been started")
            return
        }

        var configuration = LyticsConfiguration()
        configure(&configuration)

        logger.logLevel = configuration.logLevel
        defaultStream = configuration.defaultStream

        eventPipeline = EventPipeline(
            logger: logger,
            requestBuilder: .live(apiKey: configuration.apiKey),
            requestQueue: RequestQueue(
                maxQueueSize: configuration.maxQueueSize,
                uploadInterval: configuration.uploadInterval))

        hasStarted = true
    }
}

// MARK: - Events
public extension Lytics {

    /// Track a custom event.
    /// - Parameters:
    ///   - stream: The DataType, or "Table" of type of data being uploaded.
    ///   - name: The event name.
    ///   - identifiers: A value representing additional identifiers to associate with this event.
    ///   - properties: A value  representing the event properties.
    func track<I: Encodable, P: Encodable>(
        stream: String? = nil,
        name: String? = nil,
        identifiers: I?,
        properties: P?
    ) {
        guard hasStarted else {
            assertionFailure("Lytics must be started before using \(#function)")
            return
        }

        // ...

        let event = Event(name: name, identifiers: identifiers, properties: properties)
        eventPipeline.handle(stream: stream ?? defaultStream, event: event)
    }

    /// Track a custom event.
    /// - Parameters:
    ///   - stream: The DataType, or "Table" of type of data being uploaded.
    ///   - name: The event name.
    ///   - event: A value representing the event properties.
    func track<P: Encodable>(
        stream: String? = nil,
        name: String? = nil,
        properties: P?
    ) {
        track(stream: stream, name: name, identifiers: Optional.never, properties: properties)
    }

    /// Track a custom event.
    /// - Parameters:
    ///   - stream: The DataType, or "Table" of type of data being uploaded.
    ///   - name: The event name.
    func track(
        stream: String? = nil,
        name: String? = nil
    ) {
        track(stream: stream, name: name, identifiers: Optional<Never>.none, properties: Optional<Never>.none)
    }

    /// Update the user properties and optionally emit an identity event.
    /// - Parameters:
    ///   - stream: The DataType, or "Table" of type of data being uploaded.
    ///   - name: The event name.
    ///   - identifiers: A value representing user identifiers.
    ///   - attributes: A value representing additional information about a user.
    ///   - shouldSend: A Boolean value indicating whether an event should be emitted.
    func identify<I: Encodable, A: Encodable>(
        stream: String? = nil,
        name: String? = nil,
        identifiers: I?,
        attributes: A?,
        shouldSend: Bool = true
    ) {
        guard hasStarted else {
            assertionFailure("Lytics must be started before using \(#function)")
            return
        }

        if shouldSend {
            let event = IdentityEvent(name: name, identifiers: identifiers, attributes: attributes)
            eventPipeline.handle(stream: stream ?? defaultStream, event: event)
        }
        // ...
    }

    /// Update the user properties and optionally emit an identity event.
    /// - Parameters:
    ///   - stream: The DataType, or "Table" of type of data being uploaded.
    ///   - name: The event name.
    ///   - identifiers: A value representing user identifiers.
    ///   - shouldSend: A Boolean value indicating whether an event should be emitted.
    func identify<I: Encodable>(
        stream: String? = nil,
        name: String? = nil,
        identifiers: I?,
        shouldSend: Bool = true
    ) {
        identify(
            stream: stream,
            name: name,
            identifiers: identifiers,
            attributes: Optional.never,
            shouldSend: shouldSend)
    }

    /// Update a user consent properties and optionally emit a special event that represents an app user's explicit consent.
    /// - Parameters:
    ///   - stream: The DataType, or "Table" of type of data being uploaded.
    ///   - name: The event name.
    ///   - identifiers: A value representing additional identifiers to associate with this event.
    ///   - attributes: A value representing additional information about a user.
    ///   - consent: A value representing consent properties.
    ///   - shouldSend: A Boolean value indicating whether an event should be emitted.
    func consent<I: Encodable, A: Encodable, C: Encodable>(
        stream: String? = nil,
        name: String? = nil,
        identifiers: I?,
        attributes: A?,
        consent: C?,
        shouldSend: Bool = true
    ) {
        guard hasStarted else {
            assertionFailure("Lytics must be started before using \(#function)")
            return
        }

        if shouldSend {
            let event = ConsentEvent(
                name: name,
                identifiers: identifiers,
                attributes: attributes,
                consent: consent)
            eventPipeline.handle(stream: stream ?? defaultStream, event: event)
        }
        // ...
    }

    /// Update a user consent properties and optionally emit a special event that represents an app user's explicit consent.
    /// - Parameters:
    ///   - stream: The DataType, or "Table" of type of data being uploaded.
    ///   - name: The event name.
    ///   - attributes: A value representing additional information about a user.
    ///   - consent: A value representing consent properties.
    ///   - shouldSend: A Boolean value indicating whether an event should be emitted.
    func consent<A: Encodable, C: Encodable>(
        stream: String? = nil,
        name: String? = nil,
        attributes: A?,
        consent: C?,
        shouldSend: Bool = true
    ) {
        self.consent(
            stream: stream,
            name: name,
            identifiers: Optional.never,
            attributes: attributes,
            consent: consent,
            shouldSend: shouldSend)
    }

    /// Update a user consent properties and optionally emit a special event that represents an app user's explicit consent.
    /// - Parameters:
    ///   - stream: The DataType, or "Table" of type of data being uploaded.
    ///   - name: The event name.
    ///   - consent: A value representing consent properties.
    ///   - shouldSend: A Boolean value indicating whether an event should be emitted.
    func consent<C: Encodable>(
        stream: String? = nil,
        name: String? = nil,
        consent: C?,
        shouldSend: Bool = true
    ) {
        self.consent(
            stream: stream,
            name: name,
            identifiers: Optional.never,
            attributes: Optional.never,
            consent: consent,
            shouldSend: shouldSend)
    }

    /// Emit an event representing a screen or page view. Device properties are injected into the payload before emitting.
    /// - Parameters:
    ///   - stream: The DataType, or "Table" of type of data being uploaded.
    ///   - name: The event name.
    ///   - properties: A value representing the event properties.
    func screen<I: Encodable, P: Encodable>(
        stream: String? = nil,
        name: String? = nil,
        identifiers: I?,
        properties: P?
    ) {
        // ...
    }

    /// Emit an event representing a screen or page view. Device properties are injected into the payload before emitting.
    /// - Parameters:
    ///   - stream: The DataType, or "Table" of type of data being uploaded.
    ///   - name: The event name.
    ///   - properties: A value representing the event properties.
    func screen<P: Encodable>(
        stream: String? = nil,
        name: String? = nil,
        properties: P?
    ) {
        screen(stream: stream, name: name, identifiers: Optional.never, properties: properties)
    }
}

// MARK: - Tracking
public extension Lytics {

    /// Opt the user in to event collection.
    func optIn() {
        // ...
    }

    /// Opt the user out of event collection.
    func optOut() {
        // ...
    }

    /// Request access to IDFA.
    func requestTrackingAuthorization() async -> Bool {
        // ...
        return false
    }

    /// Disable use of IDFA.
    func disableTracking() {
        // ...
    }
}

// MARK: - Utility
public extension Lytics {

    /// Returns a unique identifier.
    func identifier() -> String {
        UUID().uuidString
    }

    /// Force flush the event queue by sending all events in the queue immediately.
    func dispatch() {
        // ...
    }

    /// Clear all stored user information.
    func reset() {
        // ...
    }
}
