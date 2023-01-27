//
//  EventQueueMock.swift
//
//  Created by Mathew Gacy on 11/9/22.
//

import Foundation
@testable import Lytics
import XCTest

actor EventQueueMock: EventQueueing {
    var onEnqueue: (any StreamEvent) -> Void
    var onFlush: () -> Void

    init(
        onEnqueue: @escaping (StreamEvent) -> Void = { _ in XCTFail("EventQueueMock.onEnqueue") },
        onFlush: @escaping () -> Void = { XCTFail("EventQueueMock.onFlush") }
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
