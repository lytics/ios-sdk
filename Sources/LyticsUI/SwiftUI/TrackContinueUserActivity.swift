//
//  TrackContinueUserActivity.swift
//
//  Created by Mathew Gacy on 12/4/22.
//

import Lytics
import SwiftUI

public struct TrackContinueUserActivity: ViewModifier {
    let lytics: Lytics
    let activityType: String
    let action: (NSUserActivity) -> Void

    public init(
        lytics: Lytics,
        activityType: String,
        action: @escaping (NSUserActivity) -> Void
    ) {
        self.lytics = lytics
        self.activityType = activityType
        self.action = action
    }

    public func body(content: Content) -> some View {
        content
            .onContinueUserActivity(activityType) { userActivity in
                lytics.continueUserActivity(userActivity)
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
    ///   - action: A function to call that takes a `NSUserActivity` object as its parameter when
    ///   delivering the activity to the scene or window the view is in.
    func trackContinueUserActivity(
        _ activityType: String,
        with lytics: Lytics = .shared,
        perform action: @escaping (NSUserActivity) -> Void
    ) -> some View {
        modifier(TrackContinueUserActivity(
            lytics: lytics,
            activityType: activityType,
            action: action))
    }
}
