//
//  LyticsConfiguration.swift
//
//  Created by Mathew Gacy on 9/12/22.
//

import Foundation

/// Lytics SDK configuration.
public struct LyticsConfiguration: Equatable {

    /// The base URL to which requests will be made.
    public var baseURL: URL = Constants.defaultBaseURL

    /// Additional path components for the API.
    public var apiPath: String = Constants.defaultAPIPath

    /// Default stream name to which events will be sent if not explicitly set for an event.
    public var defaultStream: String = Constants.defaultStream

    /// The key that represents the core identifier to be used in api calls.
    public var primaryIdentityKey: String = Constants.defaultPrimaryIdentityKey

    /// The key which we use to store the anonymous identifier.
    public var anonymousIdentityKey: String = Constants.defaultAnonymousIdentityKey

    /// A Boolean value indicating whether application lifecycle events should be tracked automatically.
    public var trackApplicationLifecycleEvents: Bool = false

    /// A Boolean value indicating whether screen views should be tracked automatically.
    public var trackScreenViews: Bool = false

    /// A Boolean value indicating whether push notifications should be tracked.
    public var trackPushNotifications: Bool = false

    /// A Boolean value indicating whether deep links should be tracked.
    public var trackDeepLinks: Bool = false

    /// The interval in seconds at which the event queue is uploaded to the Lytics API.
    public var uploadInterval: Double = 10

    /// The max size of the event queue before forcing an upload of the event queue to the Lytics API.
    ///
    /// Set to `0` to disable.
    public var maxQueueSize: Int = 10

    /// The max number of times to try and resend an event on failure.
    public var maxRetryCount: Int = 3

    /// Session timeout in seconds.
    ///
    /// This is the period from when the app enters the background and the session expires, starting a new session.
    public var sessionDuration: TimeInterval = 1_200

    /// Enable sandbox mode which adds a "sandbox" flag to all outbound events. This flag then enables those events to be
    /// processed in an alternative way or skipped entirely upon delivery to the Lytics collection APIs.
    public var enableSandbox: Bool = false

    /// A Boolean value indicating whether a user must explicitly opt-in to event tracking.
    public var requireConsent: Bool = false

    /// Set the logging level of the SDK.
    ///
    /// Set to `nil` to disable all logging.
    public var logLevel: LogLevel? = .error

    var apiURL: URL {
        if apiPath.isEmpty {
            return baseURL
        } else {
            return baseURL.appendingPathComponent(apiPath, isDirectory: false)
        }
    }
}
