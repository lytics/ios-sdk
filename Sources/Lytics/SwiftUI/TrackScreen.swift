//
//  TrackScreen.swift
//
//  Created by Mathew Gacy on 12/4/22.
//

import SwiftUI

public struct TrackScreen<I: Encodable, P: Encodable>: ViewModifier {
    let lytics: Lytics
    let stream: String?
    let name: String?
    let identifiers: I?
    let properties: P?

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

    public func body(content: Content) -> some View {
        content
            .onAppear {
                lytics.screen(
                    stream: stream,
                    name: name,
                    identifiers: identifiers,
                    properties: properties)
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
            properties: properties))
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
            properties: .never))
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
            properties: properties))
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
            properties: .never))
    }
}
