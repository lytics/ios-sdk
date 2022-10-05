//
//  RequestQueueing.swift
//
//  Created by Mathew Gacy on 10/1/22.
//

import Foundation

protocol RequestQueueing: Actor {
    func enqueue<T: RequestProtocol>(_ request: T)
}
