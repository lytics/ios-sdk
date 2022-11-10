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
    private let eventBuilder: AppEventProvider
    private let eventPipeline: EventPipelineProtocol
    private var trackingTask: Task<Void, Never>?

    init(
        configuration: Configuration,
        logger: LyticsLogger,
        eventBuilder: AppEventProvider,
        eventPipeline: EventPipelineProtocol
    ) {
        self.configuration = configuration
        self.logger = logger
        self.eventBuilder = eventBuilder
        self.eventPipeline = eventPipeline
    }

    /// Starts tracking application events.
    /// - Parameter lifecycleEvents: An asynchronous sequence of app lifecycle events.
    func startTracking<S: AsyncSequence>(lifecycleEvents: S) where S.Element == AppLifecycleEvent {
        trackingTask = Task {
            // App version events
            if let event = AppVersionTracker.live.checkVersion() {
                switch event {
                case .install:
                    self.logger.debug("App was installed")

                    await self.eventBuilder.appInstall()
                    |> self.sendEvent
                case .update(let version):
                    self.logger.debug("App was updated to version \(version)")

                    await self.eventBuilder.appUpdate(version: version)
                    |> self.sendEvent
                }
            }

            // App lifecycle events
            do {
                for try await event in lifecycleEvents {
                    switch event {
                    case .didBecomeActive:
                        self.logger.debug("App did become active")

                        if self.configuration.trackApplicationLifecycleEvents  {
                                await self.eventBuilder.appOpen()
                                |> self.sendEvent
                        } else {
                            SessionTracker.markInteraction(timestampProvider())
                        }

                    case .didEnterBackground:
                        self.logger.debug("App did enter background")

                        if self.configuration.trackApplicationLifecycleEvents  {
                            await self.eventBuilder.appBackground()
                            |> self.sendEvent
                        }

                    case .willTerminate:
                        self.logger.debug("App will terminate")
                    }
                }
            } catch {
                logger.error("Encountered error iterating over lifecycle events")
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
    func sendEvent<E: Encodable>(_ tuple: (String, E)) async {
        await eventPipeline.event(
            stream: configuration.stream,
            timestamp: timestampProvider(),
            name: tuple.0,
            event: tuple.1)
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
        eventPipeline: EventPipelineProtocol
    ) -> AppEventTracker {
        let eventBuilder = AppEventProvider(identifiers: { [weak userManager] in
            await userManager?.identifiers.mapValues(AnyCodable.init) ?? [:]
        })

        return .init(
            configuration: .init(configuration),
            logger: logger,
            eventBuilder: eventBuilder,
            eventPipeline: eventPipeline)
    }
}
