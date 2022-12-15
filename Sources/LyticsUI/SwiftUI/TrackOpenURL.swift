//
//  TrackOpenURL.swift
//
//  Created by Mathew Gacy on 12/4/22.
//

import Lytics
import SwiftUI

/// A `ViewModifier` that tracks reception of a url and registers a handler to invoke when the
/// modified view receives a url for the scene or window the view is in.
///
/// It is recommended to use this via the `View.trackOpenURL(with:stream:perform:)` method:
///
/// ```swift
/// var body: some View {
///     Text("A view")
///         .trackOpenURL(stream: "stream") { url in
///             // handle url ...
///         }
/// }
/// ```
public struct TrackOpenURL: ViewModifier {
    let lytics: Lytics
    let stream: String?
    let action: (URL) -> Void

    /// Creates a view modifier that tracks reception of a url and registers a handler for that url.
    /// - Parameters:
    ///   - lytics: The ``Lytics`` instance used to track the url.
    ///   - stream: The DataType, or "Table" of type of data being uploaded.
    ///   - action: A function that takes a URL object as its parameter when delivering the URL to
    ///   the scene or window the view is in.
    public init(
        lytics: Lytics,
        stream: String?,
        action: @escaping (URL) -> Void
    ) {
        self.lytics = lytics
        self.stream = stream
        self.action = action
    }

    public func body(content: Content) -> some View {
        content
            .onOpenURL { url in
                lytics.openURL(
                    url,
                    stream: stream)
                action(url)
            }
    }
}

public extension View {

    /// Tracks reception of a url and registers a handler to invoke when the view receives a url
    /// for the scene or window the view is in.
    ///
    /// Note: This method handles the reception of Universal Links, rather than a `NSUserActivity`.
    ///
    /// - Parameters:
    ///   - lytics: The ``Lytics`` instance used to track the url.
    ///   - stream: The DataType, or "Table" of type of data being uploaded.
    ///   - action: A function that takes a URL object as its parameter when delivering the URL to
    ///   the scene or window the view is in.
    func trackOpenURL(
        with lytics: Lytics = .shared,
        stream: String? = nil,
        perform action: @escaping (URL) -> Void) -> some View {
        modifier(TrackOpenURL(
            lytics: lytics,
            stream: stream,
            action: action))
    }
}
