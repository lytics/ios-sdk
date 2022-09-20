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
    public func start(_ configuration: (LyticsConfiguration) -> Void) {
        // ...
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
        // ...
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
        track(stream: stream, name: name, identifiers: Optional<Never>.none, properties: properties)
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
            attributes: Optional<Never>.none,
            shouldSend: shouldSend)
    }

    /// Update a user consent properties and optionally emit a special event that represents an app user's explicit consent.
    /// - Parameters:
    ///   - stream: The DataType, or "Table" of type of data being uploaded.
    ///   - name: The event name.
    ///   - identifiers: A value representing additional identifiers to associate with this event.
    ///   - properties: A value representing the event properties.
    ///   - consent: A value representing consent properties.
    ///   - shouldSend: A Boolean value indicating whether an event should be emitted.
    func consent<I: Encodable, P: Encodable, C: Encodable>(
        stream: String? = nil,
        name: String? = nil,
        identifiers: I?,
        properties: P?,
        consent: C?,
        shouldSend: Bool = true
    ) {
        // ...
    }

    /// Update a user consent properties and optionally emit a special event that represents an app user's explicit consent.
    /// - Parameters:
    ///   - stream: The DataType, or "Table" of type of data being uploaded.
    ///   - name: The event name.
    ///   - properties: A value representing the event properties.
    ///   - consent: A value representing consent properties.
    ///   - shouldSend: A Boolean value indicating whether an event should be emitted.
    func consent<P: Encodable, C: Encodable>(
        stream: String? = nil,
        name: String? = nil,
        properties: P?,
        consent: C?,
        shouldSend: Bool = true
    ) {
        self.consent(
            stream: stream,
            name: name,
            identifiers: Optional<Never>.none,
            properties: properties,
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
            identifiers: Optional<Never>.none,
            properties: Optional<Never>.none,
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
        screen(stream: stream, name: name, identifiers: Optional<Never>.none, properties: properties)
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
