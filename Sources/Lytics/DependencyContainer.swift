//
//  DependencyContainer.swift
//
//  Created by Mathew Gacy on 1/23/23.
//

import Foundation

/// A container for SDK dependencies.
@usableFromInline
struct DependencyContainer {
    @usableFromInline var appTrackingTransparency: AppTrackingTransparency
    @usableFromInline var configuration: LyticsConfiguration
    @usableFromInline var eventPipeline: EventPipelineProtocol
    @usableFromInline var timestampProvider: () -> Millisecond
    @usableFromInline var userManager: UserManaging
    var apiToken: String
    var appEventTracker: AppEventTracking
    var loader: Loader
}

extension DependencyContainer {
    static func live(
        apiToken: String,
        configuration: LyticsConfiguration,
        logger: LyticsLogger,
        appEventHandler: @escaping @Sendable (AppLifecycleEvent) -> Void
    ) -> Self {
        let requestBuilder = RequestBuilder.live(
            baseURL: configuration.apiURL,
            apiToken: apiToken
        )

        let eventPipeline = EventPipeline.live(
            configuration: configuration,
            logger: logger,
            requestBuilder: requestBuilder
        )

        let userManager = UserManager.live(configuration: configuration)

        return .init(
            appTrackingTransparency: .live,
            configuration: configuration,
            eventPipeline: eventPipeline,
            timestampProvider: { Date().timeIntervalSince1970.milliseconds },
            userManager: userManager,
            apiToken: apiToken,
            appEventTracker: AppEventTracker.live(
                configuration: configuration,
                logger: logger,
                userManager: userManager,
                eventPipeline: eventPipeline,
                onEvent: appEventHandler
            ),
            loader: .live(
                configuration: configuration,
                requestBuilder: requestBuilder,
                requestPerformer: URLSession.live
            )
        )
    }
}
