//
//  EventQueueing.swift
//
//  Created by Mathew Gacy on 10/16/22.
//

import Foundation

protocol EventQueueing: Actor {
    func enqueue<E: StreamEvent>(_ event: E)

    func flush()
}
