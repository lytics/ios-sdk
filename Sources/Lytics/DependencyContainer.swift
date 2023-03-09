//
//  DependencyContainer.swift
//
//  Created by Mathew Gacy on 1/23/23.
//

import Foundation

/// A container for SDK dependencies.
@usableFromInline
struct DependencyContainer {
    var apiToken: String
    var appEventTracker: AppEventTracking
    var appTrackingTransparency: AppTrackingTransparency
    var configuration: LyticsConfiguration
    var eventPipeline: EventPipelineProtocol
    var loader: Loader
    var timestampProvider: () -> Millisecond
    var userManager: UserManaging
}

extension DependencyContainer {
    static func live(
        apiToken: String,
        configuration: LyticsConfiguration,
        logger: LyticsLogger,
        appEventHandler: @escaping @Sendable (AppLifecycleEvent) -> Void
    ) -> Self {
        let requestBuilder = RequestBuilder.live(
            apiToken: apiToken,
            configuration: configuration
        )

        let eventPipeline = EventPipeline.live(
            configuration: configuration,
            logger: logger,
            requestBuilder: requestBuilder
        )

        let appTrackingTransparency = AppTrackingTransparency.live

        let userManager = UserManager.live(
            configuration: configuration,
            idfaProvider: appTrackingTransparency.idfa
        )

        return .init(
            apiToken: apiToken,
            appEventTracker: AppEventTracker.live(
                configuration: configuration,
                logger: logger,
                userManager: userManager,
                eventPipeline: eventPipeline,
                onEvent: appEventHandler
            ),
            appTrackingTransparency: appTrackingTransparency,
            configuration: configuration,
            eventPipeline: eventPipeline,
            loader: .live(
                configuration: configuration,
                requestBuilder: requestBuilder,
                requestPerformer: URLSession.live
            ),
            timestampProvider: { Date().timeIntervalSince1970.milliseconds },
            userManager: userManager
        )
    }
}
