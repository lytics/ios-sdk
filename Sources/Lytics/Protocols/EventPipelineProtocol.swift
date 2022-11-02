//
//  EventPipelineProtocol.swift
//
//  Created by Mathew Gacy on 10/23/22.
//

import Foundation

@usableFromInline
/// A class of types serving as an event pipeline.
protocol EventPipelineProtocol {

    /// A Boolean value indicating whether the user has opted in to event collection.
    var isOptedIn: Bool { get }

    /// Adds an event to the event pipeline.
    /// - Parameters:
    ///   - stream: The DataType, or "Table" of type of data being uploaded.
    ///   - timestamp: The event timestamp.
    ///   - name: The event name.
    ///   - event: The event.
    func event<E: Encodable>(
        stream: String,
        timestamp: Millisecond,
        name: String?,
        event: E
    ) async

    /// Opt the user in to event collection.
    func optIn()

    /// Opt the user out of event collection.
    func optOut()

    /// Force flush the event queue by sending all events in the queue immediately.
    func dispatch() async
}
