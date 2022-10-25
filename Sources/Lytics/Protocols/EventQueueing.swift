//
//  EventQueueing.swift
//
//  Created by Mathew Gacy on 10/16/22.
//

import Foundation

/// A type that holds a queue of events.
protocol EventQueueing: Actor {

    /// Adds an event to the queue.
    /// - Parameter event: the event to add.
    func enqueue<E: StreamEvent>(_ event: E)

    /// Sends all queued events.
    func flush()
}
