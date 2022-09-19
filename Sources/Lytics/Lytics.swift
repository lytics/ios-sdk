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
    ///   - event: An `Encodable` type representing the event properties.
    ///   - send: A Boolean value indicating whether an event should be emitted.
    func track<Event: Encodable>(
        stream: String? = nil,
        name: String,
        event: Event,
        send: Bool = true
    ) {
        // ...
    }

    /// Track a custom event.
    /// - Parameters:
    ///   - stream: The DataType, or "Table" of type of data being uploaded.
    ///   - name: The event name.
    ///   - send: A Boolean value indicating whether an event should be emitted.
    func track(
        stream: String? = nil,
        name: String,
        send: Bool = true
    ) {
        // ...
    }

    /// Update the user properties and optionally emit an identity event.
    /// - Parameters:
    ///   - stream: The DataType, or "Table" of type of data being uploaded.
    ///   - name: The event name.
    ///   - identifiers: An `Encodable` type representing user identifiers.
    ///   - traits: An `Encodable` type representing additional information about a user.
    ///   - send: A Boolean value indicating whether an event should be emitted.
    func identify<Identifiers: Encodable, Traits: Encodable>(
        stream: String? = nil,
        name: String,
        identifiers: Identifiers,
        traits: Traits,
        send: Bool = true
    ) {
        // ...
    }

    /// Update the user properties and optionally emit an identity event.
    /// - Parameters:
    ///   - stream: The DataType, or "Table" of type of data being uploaded.
    ///   - name: The event name.
    ///   - identifiers: An `Encodable` type representing user identifiers.
    ///   - send: A Boolean value indicating whether an event should be emitted.
    func identify<Identifiers: Encodable>(
        stream: String? = nil,
        name: String,
        identifiers: Identifiers,
        send: Bool = true
    ) {
        // ...
    }

    /// Update a user consent properties and optionally emit a special event that represents an app user's explicit consent.
    /// - Parameters:
    ///   - stream: The DataType, or "Table" of type of data being uploaded.
    ///   - name: The event name.
    ///   - event: An `Encodable` type representing the event properties.
    ///   - send: A Boolean value indicating whether an event should be emitted.
    func consent<Event: Encodable>(
        stream: String? = nil,
        name: String,
        event: Event,
        send: Bool = true
    ) {
        // ...
    }

    /// Emit an event representing a screen or page view. Device properties are injected into the payload before emitting.
    /// - Parameters:
    ///   - stream: The DataType, or "Table" of type of data being uploaded.
    ///   - name: The event name.
    ///   - event: An `Encodable` type representing the event properties.
    ///   - send: A Boolean value indicating whether an event should be emitted.
    func screen<Event: Encodable>(
        stream: String? = nil,
        name: String,
        event: Event,
        send: Bool = true
    ) {
        // ...
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

    func requestTrackingAuthorization() async -> Bool {
        // ...
        return false
    }

    func disableTracking() {
        // ...
    }
}

// MARK: - Utility
public extension Lytics {

    /// Force flush the event queue by sending all events in the queue immediately.
    func dispatch() {
        // ...
    }

    /// Clear all stored user information.
    func reset() {
        // ...
    }
}
