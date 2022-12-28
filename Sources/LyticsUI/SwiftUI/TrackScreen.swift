//
//  TrackScreen.swift
//
//  Created by Mathew Gacy on 12/4/22.
//

import Lytics
import SwiftUI

/// A `ViewModifier` that emits a screen event before the modified view appears.
///
/// It is recommended to use this via one of the `View.trackScreen` methods:
///
/// ```swift
/// var body: some View {
///     Text("A view")
///         .trackScreen(stream: "stream", name: "event")
/// }
/// ```
public struct TrackScreen<I: Encodable, P: Encodable>: ViewModifier {
    let lytics: Lytics
    let stream: String?
    let name: String?
    let identifiers: I?
    let properties: P?

    /// Creates a view modifier that emits a screen event before the modified view appears.
    /// - Parameters:
    ///   - lytics: The ``Lytics`` instance used to track the event.
    ///   - stream: The DataType, or "Table" of type of data being uploaded.
    ///   - name: The event name.
    ///   - identifiers: A value representing additional identifiers to associate with this event.
    ///   - properties: A value representing the event properties.
    public init(
        lytics: Lytics,
        stream: String? = nil,
        name: String? = nil,
        identifiers: I? = nil,
        properties: P? = nil
    ) {
        self.lytics = lytics
        self.stream = stream
        self.name = name
        self.identifiers = identifiers
        self.properties = properties
    }

    /// Gets the current body of the caller.
    public func body(content: Content) -> some View {
        content
            .onAppear {
                lytics.screen(
                    stream: stream,
                    name: name,
                    identifiers: identifiers,
                    properties: properties
                )
            }
    }
}

public extension View {

    /// Emits a screen event before this view appears.
    /// - Parameters:
    ///   - lytics: The ``Lytics`` instance used to track the event.
    ///   - stream: The DataType, or "Table" of type of data being uploaded.
    ///   - name: The event name.
    ///   - identifiers: A value representing additional identifiers to associate with this event.
    ///   - properties:  A value representing the event properties.
    func trackScreen<I: Encodable, P: Encodable>(
        with lytics: Lytics = .shared,
        stream: String? = nil,
        name: String? = nil,
        identifiers: I?,
        properties: P?
    ) -> some View {
        modifier(TrackScreen(
            lytics: lytics,
            stream: stream,
            name: name,
            identifiers: identifiers,
            properties: properties
        ))
    }

    /// Emits a screen event before this view appears.
    /// - Parameters:
    ///   - lytics: The ``Lytics`` instance used to track the event.
    ///   - stream: The DataType, or "Table" of type of data being uploaded.
    ///   - name: The event name.
    ///   - identifiers: A value representing additional identifiers to associate with this event.
    func trackScreen<I: Encodable>(
        with lytics: Lytics = .shared,
        stream: String? = nil,
        name: String? = nil,
        identifiers: I?
    ) -> some View {
        modifier(TrackScreen(
            lytics: lytics,
            stream: stream,
            name: name,
            identifiers: identifiers,
            properties: .never
        ))
    }

    /// Emits a screen event before this view appears.
    /// - Parameters:
    ///   - lytics: The ``Lytics`` instance used to track the event.
    ///   - stream: The DataType, or "Table" of type of data being uploaded.
    ///   - name: The event name.
    ///   - properties:  A value representing the event properties.
    func trackScreen<P: Encodable>(
        with lytics: Lytics = .shared,
        stream: String? = nil,
        name: String? = nil,
        properties: P?
    ) -> some View {
        modifier(TrackScreen(
            lytics: lytics,
            stream: stream,
            name: name,
            identifiers: .never,
            properties: properties
        ))
    }

    /// Emits a screen event before this view appears.
    /// - Parameters:
    ///   - lytics: The ``Lytics`` instance used to track the event.
    ///   - stream: The DataType, or "Table" of type of data being uploaded.
    ///   - name: The event name.
    func trackScreen(
        with lytics: Lytics = .shared,
        stream: String? = nil,
        name: String? = nil
    ) -> some View {
        modifier(TrackScreen(
            lytics: lytics,
            stream: stream,
            name: name,
            identifiers: .never,
            properties: .never
        ))
    }
}
