//
//  Lytics.swift
//
//  Created by Mathew Gacy on 9/12/22.
//

import AnyCodable
import Foundation

public final class Lytics {

    /// The shared instance.
    public static let shared: Lytics = {
        Lytics()
    }()

    @usableFromInline
    internal var logger: LyticsLogger = .live

    @usableFromInline
    internal var userManager: UserManaging!

    @usableFromInline
    internal var timestampProvider: () -> Millisecond = { Date().timeIntervalSince1970.milliseconds }

    @usableFromInline
    internal private(set) var appTrackingTransparency: AppTrackingTransparency!

    @usableFromInline
    internal var eventPipeline: EventPipeline!

    @usableFromInline
    internal private(set) var defaultStream: String = ""

    /// A Boolean value indicating whether this instance has been started.
    public private(set) var hasStarted: Bool = false

    /// A Boolean value indicating whether the user has opted into event collection.
    public var isOptedIn: Bool {
        false
    }

    /// A Boolean value indicating whether IDFA is enabled.
    public var isIDFAEnabled: Bool {
        guard hasStarted else {
            assertionFailure("Lytics must be started before accessing `isIDFAEnabled`.")
            return false
        }

        return appTrackingTransparency.idfa() != nil
    }

    /// The current Lytics user.
    public var user: LyticsUser {
        get async {
            guard hasStarted else {
                assertionFailure("Lytics must be started before accessing `user`.")
                return .init()
            }

            return await userManager.user
        }
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

        userManager = UserManager.live(configuration: configuration)
        appTrackingTransparency = .live

        eventPipeline = .live(
            logger: logger,
            configuration: configuration)

        hasStarted = true
    }
}

// MARK: - Events
public extension Lytics {

    @inlinable
    /// Track a custom event.
    /// - Parameters:
    ///   - stream: The DataType, or "Table" of type of data being uploaded.
    ///   - name: The event name.
    ///   - timestamp: A an optional custom timestamp for the event.
    ///   - identifiers: A value representing additional identifiers to associate with this event.
    ///   - properties: A value  representing the event properties.
    func track<I: Encodable, P: Encodable>(
        stream: String? = nil,
        name: String? = nil,
        timestamp: Millisecond? = nil,
        identifiers: I?,
        properties: P?
    ) {
        guard hasStarted else {
            assertionFailure("Lytics must be started before using \(#function)")
            return
        }

        let timestamp = timestamp ?? timestampProvider()
        Task(priority: .background) {
            var eventIdentifiers = [String: AnyCodable]()
            if let identifiers {
                do {
                    eventIdentifiers = try await userManager
                        .updateIdentifiers(with: identifiers)
                        .mapValues(AnyCodable.init(_:))
                } catch {
                    logger.error(error.localizedDescription)
                }
            } else {
                eventIdentifiers = await userManager.identifiers.mapValues(AnyCodable.init(_:))
            }

            await eventPipeline.event(
                stream: stream ?? defaultStream,
                timestamp: timestamp,
                name: name,
                event: Event(
                    identifiers: eventIdentifiers,
                    properties: properties))
        }
    }

    @inlinable
    /// Track a custom event.
    /// - Parameters:
    ///   - stream: The DataType, or "Table" of type of data being uploaded.
    ///   - name: The event name.
    ///   - timestamp: A an optional custom timestamp for the event.
    ///   - event: A value representing the event properties.
    func track<P: Encodable>(
        stream: String? = nil,
        name: String? = nil,
        timestamp: Millisecond? = nil,
        properties: P?
    ) {
        track(
            stream: stream,
            name: name,
            timestamp: timestamp,
            identifiers: Optional.never,
            properties: properties)
    }

    @inlinable
    /// Track a custom event.
    /// - Parameters:
    ///   - stream: The DataType, or "Table" of type of data being uploaded.
    ///   - name: The event name.
    ///   - timestamp: A an optional custom timestamp for the event.
    func track(
        stream: String? = nil,
        name: String? = nil,
        timestamp: Millisecond? = nil
    ) {
        track(
            stream: stream,
            name: name,
            timestamp: timestamp,
            identifiers: Optional.never,
            properties: Optional.never)
    }

    @inlinable
    /// Update the user properties and optionally emit an identity event.
    /// - Parameters:
    ///   - stream: The DataType, or "Table" of type of data being uploaded.
    ///   - name: The event name.
    ///   - timestamp: A an optional custom timestamp for the event.
    ///   - identifiers: A value representing user identifiers.
    ///   - attributes: A value representing additional information about a user.
    ///   - shouldSend: A Boolean value indicating whether an event should be emitted.
    func identify<I: Encodable, A: Encodable>(
        stream: String? = nil,
        name: String? = nil,
        timestamp: Millisecond? = nil,
        identifiers: I?,
        attributes: A?,
        shouldSend: Bool = true
    ) {
        guard hasStarted else {
            assertionFailure("Lytics must be started before using \(#function)")
            return
        }

        guard identifiers != nil || attributes != nil else {
            return
        }

        let timestamp = timestamp ?? timestampProvider()
        Task(priority: .background) {
            do {
                if shouldSend {
                    let user = try await userManager.update(
                        with: UserUpdate(identifiers: identifiers, attributes: attributes))

                    await eventPipeline.event(
                        stream: stream ?? defaultStream,
                        timestamp: timestamp,
                        name: name,
                        event: IdentityEvent(
                            identifiers: user.identifiers,
                            attributes: user.attributes))
                } else {
                    try await userManager.apply(
                        UserUpdate(identifiers: identifiers, attributes: attributes))
                }
            } catch {
                logger.error(error.localizedDescription)
            }
        }
    }

    @inlinable
    /// Update the user properties and optionally emit an identity event.
    /// - Parameters:
    ///   - stream: The DataType, or "Table" of type of data being uploaded.
    ///   - name: The event name.
    ///   - timestamp: A an optional custom timestamp for the event.
    ///   - identifiers: A value representing user identifiers.
    ///   - shouldSend: A Boolean value indicating whether an event should be emitted.
    func identify<I: Encodable>(
        stream: String? = nil,
        name: String? = nil,
        timestamp: Millisecond? = nil,
        identifiers: I?,
        shouldSend: Bool = true
    ) {
        identify(
            stream: stream,
            name: name,
            timestamp: timestamp,
            identifiers: identifiers,
            attributes: Optional.never,
            shouldSend: shouldSend)
    }

    @inlinable
    /// Update a user consent properties and optionally emit a special event that represents an app user's explicit consent.
    /// - Parameters:
    ///   - stream: The DataType, or "Table" of type of data being uploaded.
    ///   - name: The event name.
    ///   - timestamp: A an optional custom timestamp for the event.
    ///   - identifiers: A value representing additional identifiers to associate with this event.
    ///   - attributes: A value representing additional information about a user.
    ///   - consent: A value representing consent properties.
    ///   - shouldSend: A Boolean value indicating whether an event should be emitted.
    func consent<I: Encodable, A: Encodable, C: Encodable>(
        stream: String? = nil,
        name: String? = nil,
        timestamp: Millisecond? = nil,
        identifiers: I?,
        attributes: A?,
        consent: C?,
        shouldSend: Bool = true
    ) {
        guard hasStarted else {
            assertionFailure("Lytics must be started before using \(#function)")
            return
        }

        guard identifiers != nil || attributes != nil || consent != nil else {
            return
        }

        let timestamp = timestamp ?? timestampProvider()
        Task(priority: .background) {
            do {
                if shouldSend {
                    let user = try await userManager.update(
                        with: UserUpdate(identifiers: identifiers, attributes: attributes))

                    await eventPipeline.event(
                        stream: stream ?? defaultStream,
                        timestamp: timestamp,
                        name: name,
                        event: ConsentEvent(
                            identifiers: user.identifiers,
                            attributes: user.attributes,
                            consent: consent))
                } else {
                    try await userManager.apply(
                        UserUpdate(identifiers: identifiers, attributes: attributes))
                }
            } catch {
                logger.error(error.localizedDescription)
            }
        }
    }

    @inlinable
    /// Update a user consent properties and optionally emit a special event that represents an app user's explicit consent.
    /// - Parameters:
    ///   - stream: The DataType, or "Table" of type of data being uploaded.
    ///   - name: The event name.
    ///   - timestamp: A an optional custom timestamp for the event.
    ///   - attributes: A value representing additional information about a user.
    ///   - consent: A value representing consent properties.
    ///   - shouldSend: A Boolean value indicating whether an event should be emitted.
    func consent<A: Encodable, C: Encodable>(
        stream: String? = nil,
        name: String? = nil,
        timestamp: Millisecond? = nil,
        attributes: A?,
        consent: C?,
        shouldSend: Bool = true
    ) {
        self.consent(
            stream: stream,
            name: name,
            timestamp: timestamp,
            identifiers: Optional.never,
            attributes: attributes,
            consent: consent,
            shouldSend: shouldSend)
    }

    @inlinable
    /// Update a user consent properties and optionally emit a special event that represents an app user's explicit consent.
    /// - Parameters:
    ///   - stream: The DataType, or "Table" of type of data being uploaded.
    ///   - name: The event name.
    ///   - timestamp: A an optional custom timestamp for the event.
    ///   - consent: A value representing consent properties.
    ///   - shouldSend: A Boolean value indicating whether an event should be emitted.
    func consent<C: Encodable>(
        stream: String? = nil,
        name: String? = nil,
        timestamp: Millisecond? = nil,
        consent: C?,
        shouldSend: Bool = true
    ) {
        self.consent(
            stream: stream,
            name: name,
            timestamp: timestamp,
            identifiers: Optional.never,
            attributes: Optional.never,
            consent: consent,
            shouldSend: shouldSend)
    }

    @inlinable
    /// Emit an event representing a screen or page view. Device properties are injected into the payload before emitting.
    /// - Parameters:
    ///   - stream: The DataType, or "Table" of type of data being uploaded.
    ///   - name: The event name.
    ///   - timestamp: A an optional custom timestamp for the event.
    ///   - properties: A value representing the event properties.
    func screen<I: Encodable, P: Encodable>(
        stream: String? = nil,
        name: String? = nil,
        timestamp: Millisecond? = nil,
        identifiers: I?,
        properties: P?
    ) {
        guard hasStarted else {
            assertionFailure("Lytics must be started before using \(#function)")
            return
        }

        let timestamp = timestamp ?? timestampProvider()
        Task(priority: .background) {
            var eventIdentifiers = [String: AnyCodable]()
            if let identifiers {
                do {
                    eventIdentifiers = try await userManager
                        .updateIdentifiers(with: identifiers)
                        .mapValues(AnyCodable.init(_:))
                } catch {
                    logger.error(error.localizedDescription)
                }
            } else {
                eventIdentifiers = await userManager.identifiers.mapValues(AnyCodable.init(_:))
            }

            await eventPipeline.event(
                stream: stream ?? defaultStream,
                timestamp: timestamp,
                name: name,
                event: ScreenEvent(
                    device: Device(),
                    identifiers: eventIdentifiers,
                    properties: properties))
        }
    }

    @inlinable
    /// Emit an event representing a screen or page view. Device properties are injected into the payload before emitting.
    /// - Parameters:
    ///   - stream: The DataType, or "Table" of type of data being uploaded.
    ///   - name: The event name.
    ///   - timestamp: A an optional custom timestamp for the event.
    ///   - properties: A value representing the event properties.
    func screen<P: Encodable>(
        stream: String? = nil,
        name: String? = nil,
        timestamp: Millisecond? = nil,
        properties: P?
    ) {
        screen(
            stream: stream,
            name: name,
            timestamp: timestamp,
            identifiers: Optional.never,
            properties: properties)
    }
}

// MARK: - Tracking
public extension Lytics {

    /// Opt the user in to event collection.
    func optIn() {
        guard hasStarted else {
            assertionFailure("Lytics must be started before using \(#function)")
            return
        }

        logger.debug("Opt in")
        eventPipeline.optIn()
    }

    /// Opt the user out of event collection.
    func optOut() {
        guard hasStarted else {
            assertionFailure("Lytics must be started before using \(#function)")
            return
        }

        logger.debug("Opt out")
        eventPipeline.optOut()
    }

    /// Request access to IDFA.
    func requestTrackingAuthorization() async -> Bool {
        guard hasStarted else {
            assertionFailure("Lytics must be started before using \(#function)")
            return false
        }

        logger.debug("Requesting tracking authorization ...")
        let didAuthorize = await appTrackingTransparency.requestAuthorization()

        if didAuthorize {
            guard let idfa = appTrackingTransparency.idfa() else {
                logger.error("Unable to get IDFA despite authorization")
                return didAuthorize
            }

            let update: [String: AnyCodable] = [Constants.idfaKey: AnyCodable(idfa)]

            do {
                try await userManager.updateIdentifiers(with: update)
            } catch {
                logger.error("\(error)")
            }
        }

        return didAuthorize
    }

    /// Disable use of IDFA.
    func disableTracking() {
        logger.debug("Disable tracking")
        appTrackingTransparency.disableIDFA()
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
        logger.debug("Dispatch events")
        Task {
            await eventPipeline.dispatch()
        }
    }

    /// Clear all stored user information.
    func reset() {
        logger.debug("Reset")
        optOut()
        disableTracking()
        Task {
            await userManager.clear()
        }
    }
}
