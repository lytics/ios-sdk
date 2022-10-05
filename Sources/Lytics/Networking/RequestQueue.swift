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
            Task(priority: .medium) {
                await emptyQueue()
            }

        } else if timerTask == nil {
            // ...
        }
    }
}

private extension RequestQueue {
    func send<T: RequestProtocol>(_ request: T) async {
        do {
            let response = try await requestPerformer.perform(request)
                .validate()
                .decode()

            logger.debug("\(response)")
        } catch let error as DecodingError {
            logger.error(error.userDescription)
        } catch {
            if shouldRetry(for: error) {
                enqueue(request)
            } else {
                logger.error("Error sending `Request` \(request): \(error)")
            }
        }
    }

    func shouldRetry(for error: Error) -> Bool {
        // TODO: handle
        true
    }
}

private extension RequestQueue {
    func emptyQueue() async {
        defer { requests = [] }
        for request in requests {
            await send(request)
        }
    }
}
