//
//  AppEventTracker.swift
//
//  Created by Mathew Gacy on 10/22/22.
//

import AnyCodable
import Combine
import Foundation

/// An object that tracks application events.
final class AppEventTracker: AppEventTracking {

    /// Configuration for `AppEventTracker`.
    struct Configuration: Equatable {

        /// The stream to which events will be sent.
        let stream: String

        /// A Boolean value indicating whether application lifecycle events should be tracked automatically.
        let trackApplicationLifecycleEvents: Bool
    }

    private let configuration: Configuration
    private let logger: LyticsLogger
    private let timestampProvider: () -> Millisecond = { Date().timeIntervalSince1970.milliseconds }
    private let eventProvider: AppEventProvider
    private let eventPipeline: EventPipelineProtocol
    private let onEvent: (AppLifecycleEvent) -> Void
    private var trackingTask: Task<Void, Never>?

    init(
        configuration: Configuration,
        logger: LyticsLogger,
        eventProvider: AppEventProvider,
        eventPipeline: EventPipelineProtocol,
        onEvent: @escaping (AppLifecycleEvent) -> Void
    ) {
        self.configuration = configuration
        self.logger = logger
        self.eventProvider = eventProvider
        self.eventPipeline = eventPipeline
        self.onEvent = onEvent
    }

    /// Starts tracking application events.
    /// - Parameters:
    ///   - lifecycleEvents: An asynchronous sequence of app lifecycle events.
    ///   - versionTracker:  An app version event tracker.
    func startTracking<S: AsyncSequence>(
        lifecycleEvents: S,
        versionTracker: AppVersionTracker
    ) where S.Element == AppLifecycleEvent {
        trackingTask = Task { [weak self] in
            // App version events
            await self?.trackVersionEvents(versionTracker)

            // App lifecycle events
            do {
                for try await event in lifecycleEvents {
                    guard let self else {
                        return
                    }

                    switch event {
                    case .didBecomeActive:
                        self.logger.debug("App did become active")

                        if self.configuration.trackApplicationLifecycleEvents {
                            await self.eventProvider.appOpen()
                                |> self.sendEvent
                        } else {
                            SessionTracker.markInteraction(self.timestampProvider())
                        }

                    case .didEnterBackground:
                        self.logger.debug("App did enter background")

                        if self.configuration.trackApplicationLifecycleEvents {
                            await self.eventProvider.appBackground()
                                |> self.sendEvent
                        }

                    case .willTerminate:
                        self.logger.debug("App will terminate")
                    }

                    self.onEvent(event)
                }
            } catch {
                self?.logger.error("Encountered error iterating over lifecycle events")
            }
        }
    }

    /// Stops tracking application events.
    func stopTracking() {
        trackingTask?.cancel()
        trackingTask = nil
    }
}

private extension AppEventTracker {
    func trackVersionEvents(_ versionTracker: AppVersionTracker) async {
        if let event = versionTracker.checkVersion() {
            switch event {
            case .install:
                logger.debug("App was installed")

                await eventProvider.appInstall()
                    |> sendEvent
            case let .update(version):
                logger.debug("App was updated to version \(version)")

                await eventProvider.appUpdate(version: version)
                    |> sendEvent
            }
        }
    }

    func sendEvent<E: Encodable>(_ tuple: (String, E)) async {
        await eventPipeline.event(
            stream: configuration.stream,
            timestamp: timestampProvider(),
            name: tuple.0,
            event: tuple.1
        )
    }
}

extension AppEventTracker.Configuration {
    init(_ configuration: LyticsConfiguration) {
        self.stream = configuration.defaultStream.isNotEmpty ? configuration.defaultStream : Constants.defaultStream
        self.trackApplicationLifecycleEvents = configuration.trackApplicationLifecycleEvents
    }
}

extension AppEventTracker {
    static func live(
        configuration: LyticsConfiguration,
        logger: LyticsLogger,
        userManager: UserManaging,
        eventPipeline: EventPipelineProtocol,
        onEvent: @escaping (AppLifecycleEvent) -> Void
    ) -> AppEventTracker {
        let eventProvider = AppEventProvider(identifiers: { [weak userManager] in
            await userManager?.identifiers.mapValues(AnyCodable.init) ?? [:]
        })

        return .init(
            configuration: .init(configuration),
            logger: logger,
            eventProvider: eventProvider,
            eventPipeline: eventPipeline,
            onEvent: onEvent
        )
    }
}
