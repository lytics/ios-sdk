//
//  TrackContinueUserActivity.swift
//
//  Created by Mathew Gacy on 12/4/22.
//

import Lytics
import SwiftUI

/// A `ViewModifier` that tracks reception of the specified activity type and registers a handler
///  to invoke when the modified view receives that activity type for the scene or window the view
///  is in.
///
///  It is recommended to use this via the `View.trackContinueUserActivity(_:with:stream:perform:)`
///  method:
///
///  ```swift
/// var body: some View {
///     Text("A view")
///         .trackContinueUserActivity("com.lytics.foo") { activity in
///             // handle activity ...
///         }
/// }
///  ```
public struct TrackContinueUserActivity: ViewModifier {
    let activityType: String
    let lytics: Lytics
    let stream: String?
    let action: (NSUserActivity) -> Void

    /// Creates a view modifier that tracks the reception of a given activity type and registers a
    /// handler for that activity.
    /// - Parameters:
    ///   - activityType: The type of activity to handle.
    ///   - lytics: The ``Lytics`` instance used to track the specified activity.
    ///   - stream: The DataType, or "Table" of type of data being uploaded.
    ///   - action: A function to call that takes a `NSUserActivity` object as its parameter when
    ///   delivering the activity to the scene or window the view is in.
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
                    stream: stream
                )
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
            action: action
        ))
    }
}
