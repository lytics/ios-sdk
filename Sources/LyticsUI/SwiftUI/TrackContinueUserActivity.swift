//
//  TrackContinueUserActivity.swift
//
//  Created by Mathew Gacy on 12/4/22.
//

import Lytics
import SwiftUI

public struct TrackContinueUserActivity: ViewModifier {
    let activityType: String
    let lytics: Lytics
    let stream: String?
    let action: (NSUserActivity) -> Void

    public init(
        activityType: String,
        lytics: Lytics,
        stream: String?,
        action: @escaping (NSUserActivity) -> Void
    ) {
        self.activityType = activityType
        self.lytics = lytics
        self.stream = stream
        self.action = action
    }

    public func body(content: Content) -> some View {
        content
            .onContinueUserActivity(activityType) { userActivity in
                lytics.continueUserActivity(
                    userActivity,
                    stream: stream)
                action(userActivity)
            }
    }
}

public extension View {

    /// Tracks reception of the specified activity type and registers a handler to invoke when the
    /// view receives that activity type for the scene or window the view is in.
    /// - Parameters:
    ///   - activityType: The type of activity to handle.
    ///   - lytics: The ``Lytics`` instance used to track the specified activity.
    ///   - stream: The DataType, or "Table" of type of data being uploaded.
    ///   - action: A function to call that takes a `NSUserActivity` object as its parameter when
    ///   delivering the activity to the scene or window the view is in.
    func trackContinueUserActivity(
        _ activityType: String,
        with lytics: Lytics = .shared,
        stream: String? = nil,
        perform action: @escaping (NSUserActivity) -> Void
    ) -> some View {
        modifier(TrackContinueUserActivity(
            activityType: activityType,
            lytics: lytics,
            stream: stream,
            action: action))
    }
}
