//
//  TrackOpenURL.swift
//
//  Created by Mathew Gacy on 12/4/22.
//

import Lytics
import SwiftUI

public struct TrackOpenURL: ViewModifier {
    let lytics: Lytics
    let action: (URL) -> Void

    public init(
        lytics: Lytics,
        action: @escaping (URL) -> Void
    ) {
        self.lytics = lytics
        self.action = action
    }

    public func body(content: Content) -> some View {
        content
            .onOpenURL { url in
                lytics.openURL(url)
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
    ///   - action: A function that takes a URL object as its parameter when delivering the URL to
    ///   the scene or window the view is in.
    func trackOpenURL(
        with lytics: Lytics = .shared,
        perform action: @escaping (URL) -> Void) -> some View {
        modifier(TrackOpenURL(
            lytics: lytics,
            action: action))
    }
}
