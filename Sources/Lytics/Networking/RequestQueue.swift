//
//  RequestQueue.swift
//
//  Created by Mathew Gacy on 9/30/22.
//

import Foundation

actor RequestQueue: RequestQueueing {
    private let logger: LyticsLogger
    private var requestPerformer: RequestPerforming
    private let maxQueueSize: Int
    private let uploadInterval: TimeInterval
    private var timerTask: Task<Void, Error>?
    private var requests: [any RequestProtocol] = []

    init(
        logger: LyticsLogger = .live,
        requestPerformer: RequestPerforming = URLSession.live,
        maxQueueSize: Int,
        uploadInterval: TimeInterval
    ) {
        self.logger = logger
        self.requestPerformer = requestPerformer
        self.maxQueueSize = maxQueueSize
        self.uploadInterval = uploadInterval
    }

    func enqueue<T: RequestProtocol>(_ request: T) {
        requests.append(request)

        if requests.count >= maxQueueSize {
            // ...
        } else if timerTask == nil {
            // ...
        }
    }
}
