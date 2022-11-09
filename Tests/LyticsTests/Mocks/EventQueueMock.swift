//
//  EventQueueMock.swift
//
//  Created by Mathew Gacy on 11/9/22.
//

@testable import Lytics
import Foundation

actor EventQueueMock: EventQueueing {
    var onEnqueue: (any StreamEvent) -> Void
    var onFlush: () -> Void

    init(
        onEnqueue: @escaping (StreamEvent) -> Void = { _ in },
        onFlush: @escaping () -> Void = {}
    ) {
        self.onEnqueue = onEnqueue
        self.onFlush = onFlush
    }

    func enqueue<E: StreamEvent>(_ event: E) {
        onEnqueue(event)
    }

    func flush() {
        onFlush()
    }
}
