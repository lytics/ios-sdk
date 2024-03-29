//
//  EventQueue.swift
//
//  Created by Mathew Gacy on 10/6/22.
//

import Foundation

/// A queue of events to send.
actor EventQueue: EventQueueing {
    private let logger: LyticsLogger
    private let maxQueueSize: Int
    private let uploadInterval: TimeInterval
    private let taskPriority: TaskPriority?
    private let encoder: JSONEncoder
    private let requestBuilder: DataUploadRequestBuilder
    private(set) var eventCount: UInt = 0
    private var events: [String: [any StreamEvent]] = [:]
    private var upload: ([Request<DataUploadResponse>]) async -> Void
    private var timerTask: Task<Void, Error>?

    var hasTimerTask: Bool {
        timerTask != nil
    }

    var isEmpty: Bool {
        events.isEmpty
    }

    init(
        encoder: JSONEncoder = .init(),
        logger: LyticsLogger,
        maxQueueSize: Int,
        uploadInterval: TimeInterval,
        taskPriority: TaskPriority? = .medium,
        requestBuilder: DataUploadRequestBuilder,
        upload: @escaping ([Request<DataUploadResponse>]) async -> Void
    ) {
        self.encoder = encoder
        self.logger = logger
        self.maxQueueSize = maxQueueSize
        self.uploadInterval = uploadInterval
        self.taskPriority = taskPriority
        self.requestBuilder = requestBuilder
        self.upload = upload
    }

    deinit {
        timerTask?.cancel()
        timerTask = nil
    }

    /// Adds an event to the queue.
    /// - Parameter event: the event to add.
    func enqueue<E: StreamEvent>(_ event: E) {
        logger.debug("Enqueueing event: \(event)")

        events[event.stream, default: []].append(event)
        eventCount += 1

        if eventCount >= maxQueueSize {
            flush()
        } else if timerTask == nil {
            timerTask = makeTimer(priority: taskPriority)
        }
    }

    /// Sends all queued events to ``upload``.
    func flush() {
        cancelTimer()

        guard events.isNotEmpty else {
            return
        }

        let copy = events
        resetEvents()

        Task(priority: taskPriority) {
            do {
                let requests = try requestBuilder.requests(copy)
                await upload(requests)
            } catch {
                logger.error(error.localizedDescription)
            }
        }
    }
}

private extension EventQueue {
    func makeTimer(priority: TaskPriority? = nil) -> Task<Void, Error> {
        Task.delayed(byTimeInterval: uploadInterval, priority: priority) { [weak self] in
            await self?.flush()
        }
    }

    func cancelTimer() {
        timerTask?.cancel()
        timerTask = nil
    }

    func resetEvents() {
        events = [:]
        eventCount = 0
    }
}

extension EventQueue {
    static func live(
        logger: LyticsLogger,
        configuration: LyticsConfiguration,
        requestBuilder: RequestBuilder,
        upload: @escaping ([Request<DataUploadResponse>]) async -> Void
    ) -> EventQueue {
        EventQueue(
            logger: logger,
            maxQueueSize: configuration.maxQueueSize,
            uploadInterval: configuration.uploadInterval,
            requestBuilder: .live(
                requestBuilder: requestBuilder,
                dryRun: configuration.enableSandbox
            ),
            upload: upload
        )
    }
}
