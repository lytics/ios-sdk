//
//  Lytics.swift
//
//  Created by Mathew Gacy on 9/12/22.
//

import AnyCodable
import Foundation
import UIKit

/// The Lytics SDK entry point.
public final class Lytics {

    /// The shared instance.
    public static let shared: Lytics = .init()

    /// A function which is called when an internal sanity check fails.
    private let assertionFailure: (@autoclosure @escaping () -> String, StaticString, UInt) -> Void

    /// The logger.
    @usableFromInline internal var logger: LyticsLogger

    /// The SDK dependencies.
    @usableFromInline internal var dependencies: DependencyContainer!

    /// The priority for tasks.
    @usableFromInline internal var taskPriority: TaskPriority?

    /// A Boolean value indicating whether this instance has been started.
    public var hasStarted: Bool {
        dependencies != nil
    }

    /// A Boolean value indicating whether the user has opted in to event collection.
    public var isOptedIn: Bool {
        guard hasStarted() else {
            return false
        }
        return dependencies.eventPipeline.isOptedIn
    }

    /// A Boolean value indicating whether IDFA is enabled.
    public var isIDFAEnabled: Bool {
        guard hasStarted() else {
            return false
        }
        return dependencies.appTrackingTransparency.idfa() != nil
    }

    /// The current Lytics user.
    public var user: LyticsUser {
        get async {
            guard hasStarted() else {
                return .init()
            }
            return await dependencies.userManager.user
        }
    }

    /// Creates a Lytics instance.
    ///
    /// > Warning: You must call ``start(apiToken:configure:)`` before using the created instance.
    public convenience init() {
        self.init(
            logger: .live,
            eventTaskPriority: .low
        )
    }

    internal init(
        assertionFailure: @escaping (@autoclosure @escaping () -> String, StaticString, UInt) -> Void = Swift.assertionFailure,
        logger: LyticsLogger,
        eventTaskPriority: TaskPriority? = nil,
        dependencies: DependencyContainer? = nil
    ) {
        self.assertionFailure = assertionFailure
        self.logger = logger
        self.taskPriority = eventTaskPriority
        self.dependencies = dependencies
    }

    /// Configures this Lytics SDK instance.
    ///
    /// You must configure the SDK with an [API token](https://learn.lytics.com/documentation/product/features/account-management/managing-api-tokens)
    /// before using it:
    ///
    /// ```swift
    /// Lytics.shared.start(apiToken: "YOUR-VALID-LYTICS-API-TOKEN")
    /// ```
    ///
    /// Use the optional trailing closure for additional configuration:
    ///
    /// ```swift
    /// Lytics.shared.start(apiToken: "YOUR-VALID-LYTICS-API-TOKEN") {
    ///     $0.logLevel = .debug
    ///     $0.defaultStream = "my_custom_ios_stream"
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - apiToken: A Lytics account API token.
    ///   - configure: A closure enabling mutation of the configuration.
    public func start(apiToken: String, configure: ((inout LyticsConfiguration) -> Void)? = nil) {
        guard !hasStarted else {
            logger.error("Lytics instance has already been started")
            return
        }

        guard apiToken.isNotEmpty else {
            assertionFailure("Lytics must be started with a non-empty API token", #file, #line)
            return
        }

        var configuration = LyticsConfiguration()
        if let configure {
            configure(&configuration)
        }

        if configuration.anonymousIdentityKey.isEmpty {
            configuration.anonymousIdentityKey = Constants.defaultAnonymousIdentityKey
        }
        if configuration.primaryIdentityKey.isEmpty {
            configuration.primaryIdentityKey = Constants.defaultPrimaryIdentityKey
        }

        logger.logLevel = configuration.logLevel

        dependencies = .live(
            apiToken: apiToken,
            configuration: configuration,
            logger: logger,
            appEventHandler: { [weak self] event in
                if case .didEnterBackground = event {
                    self?.dispatch()
                }
            }
        )

        dependencies.appEventTracker.startTracking(
            lifecycleEvents: NotificationCenter.default.lifecycleEvents(),
            versionTracker: AppVersionTracker.live
        )
    }

    /// Returns a Boolean indicating whether this instance has been started.
    ///
    /// This will call `assertionFailure` if called before the instance has been started.
    private func hasStarted(
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line
    ) -> Bool {
        guard hasStarted else {
            assertionFailure("Lytics must be started before accessing `\(function)`.", file, line)
            return false
        }
        return true
    }
}

// MARK: - Events
public extension Lytics {

    /// Tracks a custom event.
    ///
    /// Start by defining types to represent the identifiers and properties you wish to track:
    ///
    /// ```swift
    /// struct MyIdentifiers: Codable {
    ///     var email: String
    /// }
    ///
    /// struct MyPurchaseEvent: Codeable {
    ///     var total: Double
    ///     var item: String
    /// }
    /// ```
    ///
    /// Then, call the track method with instances of these types:
    ///
    /// ```swift
    /// Lytics.shared.track(
    ///     stream: "sample-custom-stream", // Optional
    ///     name: "purchase",               // Optional
    ///     identifiers: MyIdentifiers(email: "kevin@homealone.com"),
    ///     properties: MyPurchaseEvent(total: 19.99, item: "Slingshot")
    /// )
    /// ```
    ///
    /// - Parameters:
    ///   - stream: The DataType, or "Table" of type of data being uploaded.
    ///   - name: The event name.
    ///   - timestamp: A custom timestamp for the event.
    ///   - identifiers: A value representing additional identifiers to associate with this event.
    ///   - properties: A value representing the event properties.
    @inlinable
    func track<I: Codable, P: Codable>(
        stream: String? = nil,
        name: String? = nil,
        timestamp: Millisecond? = nil,
        identifiers: I?,
        properties: P?
    ) {
        let eventProvider: @Sendable ([String: AnyCodable]) -> Event = { .init(identifiers: $0, properties: properties) }
        if let identifiers {
            updateIdentifiersAndUpload(
                stream: stream,
                name: name,
                timestamp: timestamp,
                identifiers: identifiers,
                eventProvider: eventProvider
            )
        } else {
            upload(stream: stream, name: name, timestamp: timestamp, eventProvider: eventProvider)
        }
    }

    /// Tracks a custom event.
    ///
    /// See ``consent(stream:name:timestamp:attributes:consent:shouldSend:)`` for a full code sample.
    ///
    /// - Parameters:
    ///   - stream: The DataType, or "Table" of type of data being uploaded.
    ///   - name: The event name.
    ///   - timestamp: A custom timestamp for the event.
    ///   - event: A value representing the event properties.
    @inlinable
    func track<P: Codable>(
        stream: String? = nil,
        name: String? = nil,
        timestamp: Millisecond? = nil,
        properties: P?
    ) {
        upload(stream: stream, name: name, timestamp: timestamp) { Event(identifiers: $0, properties: properties) }
    }

    /// Tracks a custom event.
    ///
    /// See ``track(stream:name:timestamp:identifiers:properties:)`` for a full code sample.
    ///
    /// - Parameters:
    ///   - stream: The DataType, or "Table" of type of data being uploaded.
    ///   - name: The event name.
    ///   - timestamp: A custom timestamp for the event.
    @inlinable
    func track(
        stream: String? = nil,
        name: String? = nil,
        timestamp: Millisecond? = nil
    ) {
        upload(stream: stream, name: name, timestamp: timestamp) { Event(identifiers: $0, properties: Optional.never) }
    }

    /// Updates the user properties and optionally emit an identity event.
    ///
    /// Start by defining types to represent identifiers and attributes you wish to track:
    ///
    /// ```swift
    /// struct MyIdentifiers: Codable {
    ///     var email: String
    /// }
    ///
    /// struct MyAttributes: Codable {
    ///     var firstName: String
    ///     var lastName: String
    /// }
    /// ```
    ///
    /// Then, call the identify method with instances of these types:
    ///
    /// ```swift
    /// Lytics.shared.identify(
    ///     stream: "sample-custom-stream", // Optional
    ///     name: "sample-custom-name",     // Optional
    ///     identifiers: MyIdentifiers(email: "kevin@homealone.com"),
    ///     attributes: MyAttributes(firstName: "Kevin", lastName: "McCallister")
    /// )
    /// ```
    ///
    /// - Parameters:
    ///   - stream: The DataType, or "Table" of type of data being uploaded.
    ///   - name: The event name.
    ///   - timestamp: A custom timestamp for the event.
    ///   - identifiers: A value representing user identifiers.
    ///   - attributes: A value representing additional information about a user.
    ///   - shouldSend: A Boolean value indicating whether an event should be emitted.
    @inlinable
    func identify<I: Codable, A: Codable>(
        stream: String? = nil,
        name: String? = nil,
        timestamp: Millisecond? = nil,
        identifiers: I?,
        attributes: A?,
        shouldSend: Bool = true
    ) {
        let userUpdate = UserUpdate(identifiers: identifiers, attributes: attributes)
        if shouldSend {
            updateUserAndUpload(
                stream: stream,
                name: name,
                timestamp: timestamp,
                userUpdate: userUpdate
            ) { user in
                IdentityEvent(
                    identifiers: user.identifiers,
                    attributes: user.attributes
                )
            }
        } else {
            updateUser(with: userUpdate)
        }
    }

    /// Updates the user properties and optionally emit an identity event.
    ///
    /// See ``identify(stream:name:timestamp:identifiers:attributes:shouldSend:)`` for a full code sample.
    ///
    /// - Parameters:
    ///   - stream: The DataType, or "Table" of type of data being uploaded.
    ///   - name: The event name.
    ///   - timestamp: A custom timestamp for the event.
    ///   - identifiers: A value representing user identifiers.
    ///   - shouldSend: A Boolean value indicating whether an event should be emitted.
    @inlinable
    func identify<I: Codable>(
        stream: String? = nil,
        name: String? = nil,
        timestamp: Millisecond? = nil,
        identifiers: I?,
        shouldSend: Bool = true
    ) {
        let userUpdate = UserUpdate(identifiers: identifiers, attributes: Optional.never)
        if shouldSend {
            updateUserAndUpload(
                stream: stream,
                name: name,
                timestamp: timestamp,
                userUpdate: userUpdate
            ) { user in
                IdentityEvent(
                    identifiers: user.identifiers,
                    attributes: user.attributes
                )
            }
        } else {
            updateUser(with: userUpdate)
        }
    }

    /// Updates a user consent properties and optionally emit a special event that represents an app user's explicit consent.
    ///
    /// Start by defining types to represent identifiers, attributes, and consent-specific information you wish to track:
    ///
    /// ```swift
    /// struct MyIdentifiers: Codable {
    ///     var userID: String
    /// }
    ///
    /// struct MyAttributes: Codable {
    ///     var firstName: String
    ///     var lastName: String
    /// }
    ///
    /// struct MyConsent: Codable {
    ///     var documents: [String]
    ///     var location: String
    ///     var consented: Bool
    /// }
    /// ```
    ///
    /// Then, call the identify method with instances of these types:
    ///
    /// ```swift
    /// Lytics.shared.consent(
    ///     stream: "sample-custom-stream", // Optional
    ///     name: "sample-custom-name",     // Optional
    ///     identifiers: MyIdentifiers(userID: "my-fake-userid-1234"),
    ///     attributes: MyAttributes("firstName": "Kevin", "lastName": "McCalister"),
    ///     consent: MyConsent(
    ///         documents: ["terms_jan_2023", "sharing_policy_jan_2023"],
    ///         location: "Chicago, IL",
    ///         consented: true
    ///     )
    /// )
    /// ```
    ///
    /// - Parameters:
    ///   - stream: The DataType, or "Table" of type of data being uploaded.
    ///   - name: The event name.
    ///   - timestamp: A custom timestamp for the event.
    ///   - identifiers: A value representing additional identifiers to associate with this event.
    ///   - attributes: A value representing additional information about a user.
    ///   - consent: A value representing consent properties.
    ///   - shouldSend: A Boolean value indicating whether an event should be emitted.
    @inlinable
    func consent<I: Codable, A: Codable, C: Codable>(
        stream: String? = nil,
        name: String? = nil,
        timestamp: Millisecond? = nil,
        identifiers: I?,
        attributes: A?,
        consent: C?,
        shouldSend: Bool = true
    ) {
        let userUpdate = UserUpdate(identifiers: identifiers, attributes: attributes)
        guard userUpdate.hasContent || consent != nil else {
            return
        }

        if shouldSend {
            updateUserAndUpload(
                stream: stream,
                name: name,
                timestamp: timestamp,
                userUpdate: userUpdate
            ) { user in
                ConsentEvent(
                    identifiers: user.identifiers,
                    attributes: user.attributes,
                    consent: consent
                )
            }
        } else {
            updateUser(with: userUpdate)
        }
    }

    /// Updates a user consent properties and optionally emit a special event that represents an app user's explicit consent.
    ///
    /// See ``consent(stream:name:timestamp:attributes:consent:shouldSend:)`` for a full code sample.
    ///
    /// - Parameters:
    ///   - stream: The DataType, or "Table" of type of data being uploaded.
    ///   - name: The event name.
    ///   - timestamp: A custom timestamp for the event.
    ///   - attributes: A value representing additional information about a user.
    ///   - consent: A value representing consent properties.
    ///   - shouldSend: A Boolean value indicating whether an event should be emitted.
    @inlinable
    func consent<A: Codable, C: Codable>(
        stream: String? = nil,
        name: String? = nil,
        timestamp: Millisecond? = nil,
        attributes: A?,
        consent: C?,
        shouldSend: Bool = true
    ) {
        let userUpdate = UserUpdate(identifiers: Optional.never, attributes: attributes)
        guard userUpdate.hasContent || consent != nil else {
            return
        }

        if shouldSend {
            updateUserAndUpload(
                stream: stream,
                name: name,
                timestamp: timestamp,
                userUpdate: userUpdate
            ) { user in
                ConsentEvent(
                    identifiers: user.identifiers,
                    attributes: user.attributes,
                    consent: consent
                )
            }
        } else {
            updateUser(with: userUpdate)
        }
    }

    /// Updates a user consent properties and optionally emit a special event that represents an app user's explicit consent.
    ///
    /// See ``consent(stream:name:timestamp:attributes:consent:shouldSend:)`` for a full code sample.
    ///
    /// - Parameters:
    ///   - stream: The DataType, or "Table" of type of data being uploaded.
    ///   - name: The event name.
    ///   - timestamp: A custom timestamp for the event.
    ///   - consent: A value representing consent properties.
    ///   - shouldSend: A Boolean value indicating whether an event should be emitted.
    @inlinable
    func consent<C: Codable>(
        stream: String? = nil,
        name: String? = nil,
        timestamp: Millisecond? = nil,
        consent: C?,
        shouldSend: Bool = true
    ) {
        let userUpdate = UserUpdate(identifiers: Optional.never, attributes: Optional.never)
        guard userUpdate.hasContent || consent != nil else {
            return
        }

        if shouldSend {
            updateUserAndUpload(
                stream: stream,
                name: name,
                timestamp: timestamp,
                userUpdate: userUpdate
            ) { user in
                ConsentEvent(
                    identifiers: user.identifiers,
                    attributes: user.attributes,
                    consent: consent
                )
            }
        } else {
            updateUser(with: userUpdate)
        }
    }

    /// Emits an event representing a screen or page view. Device properties are injected into the payload before emitting.
    ///
    /// Start by defining types to represent the identifiers and properties you wish to track:
    ///
    /// ```swift
    /// struct MyIdentifiers: Codable {
    ///     var email: String
    /// }
    ///
    /// struct MyPurchaseEvent: Codeable {
    ///     var total: Double
    ///     var item: String
    /// }
    /// ```
    ///
    /// Then, call the screen method with instances of these types:
    ///
    /// ```swift
    /// Lytics.shared.screen(
    ///     stream: "sample-custom-stream", // Optional
    ///     name: "purchase",               // Optional
    ///     identifiers: MyIdentifiers(email: "kevin@homealone.com"),
    ///     properties: MyPurchaseEvent(total: 19.99, item: "Slingshot")
    /// )
    /// ```
    ///
    /// - Parameters:
    ///   - stream: The DataType, or "Table" of type of data being uploaded.
    ///   - name: The event name.
    ///   - timestamp: A custom timestamp for the event.
    ///   - identifiers:  A value representing additional identifiers to associate with this event.
    ///   - properties: A value representing the event properties.
    @inlinable
    func screen<I: Codable, P: Codable>(
        stream: String? = nil,
        name: String? = nil,
        timestamp: Millisecond? = nil,
        identifiers: I?,
        properties: P?
    ) {
        let eventProvider: @Sendable ([String: AnyCodable]) -> ScreenEvent = { eventIdentifiers in
            ScreenEvent(
                device: Device(),
                identifiers: eventIdentifiers,
                properties: properties
            )
        }

        if let identifiers {
            updateIdentifiersAndUpload(
                stream: stream,
                name: name,
                timestamp: timestamp,
                identifiers: identifiers,
                eventProvider: eventProvider
            )
        } else {
            upload(stream: stream, name: name, timestamp: timestamp, eventProvider: eventProvider)
        }
    }

    /// Emits an event representing a screen or page view. Device properties are injected into the payload before emitting.
    ///
    /// See ``screen(stream:name:timestamp:identifiers:properties:)`` for a full code sample.
    ///
    /// - Parameters:
    ///   - stream: The DataType, or "Table" of type of data being uploaded.
    ///   - name: The event name.
    ///   - timestamp: A custom timestamp for the event.
    ///   - properties: A value representing the event properties.
    @inlinable
    func screen<P: Codable>(
        stream: String? = nil,
        name: String? = nil,
        timestamp: Millisecond? = nil,
        properties: P?
    ) {
        upload(stream: stream, name: name, timestamp: timestamp) { eventIdentifiers in
            ScreenEvent(
                device: Device(),
                identifiers: eventIdentifiers,
                properties: properties
            )
        }
    }
}

// MARK: - Event Helpers
internal extension Lytics {

    /// Updates the current user with the given update.
    /// - Parameters:
    ///   - userUpdate: An update to apply to the current user.
    @usableFromInline
    func updateUser<I: Encodable, A: Encodable>(
        with userUpdate: UserUpdate<I, A>,
        function: StaticString = #function
    ) {
        guard hasStarted() else {
            return
        }

        guard userUpdate.hasContent else {
            return
        }

        Task(priority: taskPriority) {
            do {
                try await dependencies.userManager.apply(userUpdate)
            } catch {
                logger.error(error.localizedDescription)
            }
        }
    }

    /// Uploads an event.
    /// - Parameters:
    ///   - stream: The DataType, or "Table" of type of data being uploaded.
    ///   - name: The event name.
    ///   - timestamp: A custom timestamp for the event.
    ///   - eventProvider: A closure returning the event to send.
    @usableFromInline
    func upload<E: Encodable>(
        stream: String?,
        name: String?,
        timestamp: Millisecond?,
        function: StaticString = #function,
        eventProvider: @escaping @Sendable ([String: AnyCodable]) -> E
    ) {
        guard hasStarted() else {
            return
        }

        let timestamp = timestamp ?? dependencies.timestampProvider()
        Task(priority: taskPriority) {
            let eventIdentifiers = await dependencies.userManager.identifiers.mapValues(AnyCodable.init(_:))

            await dependencies.eventPipeline.event(
                stream: stream,
                timestamp: timestamp,
                name: name,
                event: eventProvider(eventIdentifiers)
            )
        }
    }

    /// Updates the current user identifiers and uploads an event.
    /// - Parameters:
    ///   - stream: The DataType, or "Table" of type of data being uploaded.
    ///   - name: The event name.
    ///   - timestamp: A custom timestamp for the event.
    ///   - identifiers: A value representing additional identifiers to associate with this event.
    ///   - eventProvider: A closure returning the event to send.
    @usableFromInline
    func updateIdentifiersAndUpload<I: Encodable, E: Encodable>(
        stream: String?,
        name: String?,
        timestamp: Millisecond?,
        identifiers: I,
        function: StaticString = #function,
        eventProvider: @escaping @Sendable ([String: AnyCodable]) -> E
    ) {
        guard hasStarted() else {
            return
        }

        let timestamp = timestamp ?? dependencies.timestampProvider()
        Task(priority: taskPriority) {
            var eventIdentifiers = [String: AnyCodable]()

            do {
                eventIdentifiers = try await dependencies.userManager
                    .updateIdentifiers(with: identifiers)
                    .mapValues(AnyCodable.init(_:))
            } catch {
                logger.error(error.localizedDescription)
            }

            await dependencies.eventPipeline.event(
                stream: stream,
                timestamp: timestamp,
                name: name,
                event: eventProvider(eventIdentifiers)
            )
        }
    }

    /// Updates the current user with the given update and uploads an event.
    /// - Parameters:
    ///   - stream: The DataType, or "Table" of type of data being uploaded.
    ///   - name: The event name.
    ///   - timestamp: A custom timestamp for the event.
    ///   - userUpdate: An update to apply to the current user.
    ///   - eventProvider: A closure returning the event to send.
    @usableFromInline
    func updateUserAndUpload<I: Encodable, A: Encodable, E: Encodable>(
        stream: String?,
        name: String?,
        timestamp: Millisecond?,
        userUpdate: UserUpdate<I, A>,
        function: StaticString = #function,
        eventProvider: @escaping @Sendable (LyticsUser) -> E
    ) {
        guard hasStarted() else {
            return
        }

        let timestamp = timestamp ?? dependencies.timestampProvider()
        Task(priority: taskPriority) {
            do {
                let user = userUpdate.hasContent ?
                    try await dependencies.userManager.update(with: userUpdate) :
                    await dependencies.userManager.user

                await dependencies.eventPipeline.event(
                    stream: stream,
                    timestamp: timestamp,
                    name: name,
                    event: eventProvider(user)
                )
            } catch {
                logger.error(error.localizedDescription)
            }
        }
    }
}

// MARK: - Personalization
public extension Lytics {

    /// Returns the current user with a user profile from the Entity API.
    ///
    /// This method fetches a user profile from the table specified by the ``Lytics/LyticsConfiguration/defaultTable``
    /// of the `LyticsConfiguration` instance passed to ``start(apiToken:configure:)``. By default,
    /// it will use the value of current user's primary identity key as defined by
    /// ``Lytics/LyticsConfiguration/primaryIdentityKey`` of that configuration instance. If an
    /// entity identifier is specified it will instead use that.
    ///
    /// - Parameter identifier: An optional field name and value used to fetch an entity.
    /// - Returns: The current user.
    func getProfile(
        _ identifier: EntityIdentifier? = nil
    ) async throws -> LyticsUser {
        guard hasStarted() else {
            throw LyticsError(reason: "Lytics must be started before accessing `\(#function)`.")
        }

        var user = await self.user

        let entityIdentifier: EntityIdentifier
        if let identifier {
            entityIdentifier = identifier
        } else {
            let name = dependencies.configuration.primaryIdentityKey
            guard let value = user.identifiers[name]?.description else {
                throw LyticsError(reason: "Missing value for field `\(name)`.")
            }
            entityIdentifier = EntityIdentifier(name: name, value: value)
        }

        let entity = try await dependencies.loader.entity(
            dependencies.configuration.defaultTable,
            entityIdentifier
        )

        user.profile = entity.data
        return user
    }
}

// MARK: - App Events
public extension Lytics {

    /// Tracks a request to continue an activity.
    ///
    /// Use this method to track universal links. For example, if you are using a `SceneDelegate`, call this method
    /// when handling universal links in the `scene(_:willConnectTo:options:)` and ` scene(_:continue:)` delegate
    /// methods:
    ///
    /// ```swift
    /// class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    ///     var window: UIWindow?
    ///
    ///     func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    ///         if let userActivity = connectionOptions.userActivities.first {
    ///             Lytics.shared.continueUserActivity(
    ///                 userActivity,
    ///                 stream: "sample-custom-stream" // Optional
    ///             )
    ///             // Handle user activity ...
    ///         }
    ///         // ...
    ///     }
    ///
    ///     func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
    ///         Lytics.shared.continueUserActivity(userActivity)
    ///         // Handle user activity ...
    ///     }
    /// }
    /// ```
    ///
    /// If using SwiftUI, consider calling `View.trackContinueUserActivity(_:with:stream:perform:)` from the `LyticsUI`
    /// library in place of `View.onContinueUserActivity(_:perform:)`.
    ///
    /// - Parameters:
    ///   - userActivity: The activity object containing the data associated with the task the user was performing.
    ///   - stream: The DataType, or "Table" of type of data being uploaded.
    func continueUserActivity(
        _ userActivity: NSUserActivity,
        stream: String? = nil
    ) {
        let event = UserActivityEvent(userActivity)
        upload(stream: stream, name: EventNames.deepLink, timestamp: nil) { eventIdentifiers in
            var copy = event
            copy.identifiers = eventIdentifiers
            return copy
        }
    }

    /// Tracks a request to open a resource specified by a URL.
    ///
    /// Use this method to track deep links. For example, if using an `AppDelegate`, call this method when handling
    /// deep links in `application(_:open:options:)`:
    ///
    /// ```swift
    /// class AppDelegate: NSObject, UIApplicationDelegate {
    ///
    ///     func application(
    ///         _ app: UIApplication,
    ///         open url: URL,
    ///         options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ///     ) -> Bool {
    ///         Lytics.shared.openURL(
    ///             url,
    ///             options: options,
    ///             stream: "sample-custom-stream" // Optional
    ///         )
    ///         // Handle link ...
    ///     }
    /// }
    /// ```
    ///
    /// If using SwiftUI, consider using the `View.trackOpenURL(with:stream:perform:)` method from the `LyticsUI`
    /// library in place of `View.onOpenURL(perform:)`.
    ///
    /// - Parameters:
    ///   - url: The URL resource to open.
    ///   - options: A dictionary of URL handling options.
    ///   - stream: The DataType, or "Table" of type of data being uploaded.
    func openURL(
        _ url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any]? = nil,
        stream: String? = nil
    ) {
        upload(stream: stream, name: EventNames.url, timestamp: nil) { eventIdentifiers in
            URLEvent(url: url, options: options, identifiers: eventIdentifiers)
        }
    }

    /// Tracks the selection of a Home screen quick action.
    ///
    /// Use this method to track quick actions. For example, call it when handling actions in
    /// `AppDelegate.application(_:performActionFor:completionHandler:)`:
    ///
    /// ```swift
    /// class AppDelegate: NSObject, UIApplicationDelegate {
    ///
    ///     func application(
    ///         _ application: UIApplication,
    ///         performActionFor shortcutItem: UIApplicationShortcutItem,
    ///         completionHandler: @escaping (Bool) -> Void
    ///     ) {
    ///         Lytics.shared.shortcutItem(
    ///             shortcutItem,
    ///             stream: "sample-custom-stream" // Optional
    ///         )
    ///         // Handle shortcut item ...
    ///     }
    /// }
    /// ```
    /// 
    /// - Parameters:
    ///   - shortcutItem: The selected quick action.
    ///   - stream: The DataType, or "Table" of type of data being uploaded.
    func shortcutItem(
        _ shortcutItem: UIApplicationShortcutItem,
        stream: String? = nil
    ) {
        let event = ShortcutEvent(shortcutItem)
        upload(stream: stream, name: EventNames.shortcut, timestamp: nil) { eventIdentifiers in
            var copy = event
            copy.identifiers = eventIdentifiers
            return copy
        }
    }
}

// MARK: - Tracking
public extension Lytics {

    /// Opts the user in to event collection.
    func optIn() {
        guard hasStarted() else {
            return
        }

        logger.debug("Opt in")
        dependencies.eventPipeline.optIn()
    }

    /// Opts the user out of event collection.
    func optOut() {
        guard hasStarted() else {
            return
        }

        logger.debug("Opt out")
        dependencies.eventPipeline.optOut()
    }

    /// Requests access to IDFA.
    func requestTrackingAuthorization() async -> Bool {
        guard hasStarted() else {
            return false
        }

        logger.debug("Requesting tracking authorization ...")
        let didAuthorize = await dependencies.appTrackingTransparency.requestAuthorization()

        if didAuthorize {
            guard let idfa = dependencies.appTrackingTransparency.idfa() else {
                logger.error("Unable to get IDFA despite authorization")
                return didAuthorize
            }

            let update: [String: AnyCodable] = [Constants.idfaKey: AnyCodable(idfa)]

            do {
                try await dependencies.userManager.updateIdentifiers(with: update)
            } catch {
                logger.error("\(error)")
            }
        }

        return didAuthorize
    }

    /// Disables use of IDFA.
    func disableTracking() {
        guard hasStarted() else {
            return
        }

        logger.debug("Disable tracking")
        dependencies.appTrackingTransparency.disableIDFA()
    }
}

// MARK: - Utility
public extension Lytics {

    /// Returns a unique identifier.
    func identifier() -> String {
        UUID().uuidString
    }

    /// Flushes the event queue by sending all events in the queue immediately.
    func dispatch() {
        guard hasStarted() else {
            return
        }

        logger.debug("Dispatch events")
        Task {
            await dependencies.eventPipeline.dispatch()
        }
    }

    /// Clears all stored user information.
    func reset() {
        guard hasStarted() else {
            return
        }

        logger.debug("Reset")
        optOut()
        disableTracking()
        Task {
            await dependencies.userManager.clear()
        }
    }

    /// Removes the identifier at the specified dictionary path.
    /// - Parameter path: A dictionary path to the identifier to remove.
    func removeIdentifier(_ path: DictionaryPath) {
        Task {
            await dependencies.userManager.removeIdentifier(path)
        }
    }

    /// Removes the attribute at the specified dictionary path.
    /// - Parameter path: A dictionary path to the attribute to remove.
    func removeAttribute(_ path: DictionaryPath) {
        Task {
            await dependencies.userManager.removeAttribute(path)
        }
    }
}
