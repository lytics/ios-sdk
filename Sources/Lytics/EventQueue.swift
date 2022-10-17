//
//  EventQueue.swift
//
//  Created by Mathew Gacy on 10/6/22.
//

import Foundation

actor EventQueue: EventQueueing {
    private let logger: LyticsLogger
    private let maxQueueSize: Int
    private let uploadInterval: TimeInterval

    init(
        logger: LyticsLogger,
        maxQueueSize: Int,
        uploadInterval: TimeInterval
    ) {
        self.logger = logger
        self.maxQueueSize = maxQueueSize
        self.uploadInterval = uploadInterval
    }

    /// Adds an event to the queue.
    /// - Parameter event: the event to add.
    func enqueue<E: StreamEvent>(_ event: E) {
    }

    func flush() {
    }
}

extension EventQueue {
    static func live(
        logger: LyticsLogger,
        configuration: LyticsConfiguration
    ) -> EventQueue {
        EventQueue(
            logger: logger,
            maxQueueSize: configuration.maxQueueSize,
            uploadInterval: configuration.uploadInterval)
    }
}
