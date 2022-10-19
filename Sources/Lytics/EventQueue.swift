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
    private let encoder: JSONEncoder
    private let requestBuilder: DataUploadRequestBuilder
    private var events: [String: [any StreamEvent]] = [:]
    private var eventCount: UInt = 0
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
        requestBuilder: DataUploadRequestBuilder,
        upload: @escaping ([Request<DataUploadResponse>]) async -> Void
    ) {
        self.encoder = encoder
        self.logger = logger
        self.maxQueueSize = maxQueueSize
        self.uploadInterval = uploadInterval
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
        events[event.stream, default: []].append(event)
        eventCount += 1

        if eventCount >= maxQueueSize {
            flush()
        } else if timerTask == nil {
            timerTask = makeTimer()
        }
    }

    /// Sends all queued events to ``upload``.
    func flush() {
        cancelTimer()

        guard events.isNotEmpty else {
            return
        }

        do {
            let requests = try requestBuilder.requests(events)
            events = [:]

            Task(priority: .medium) {
                await upload(requests)
            }

        } catch {
            logger.error(error.localizedDescription)
        }
    }
}

// MARK: - Timer Management
private extension EventQueue {
    func makeTimer(priority: TaskPriority = .background) -> Task<Void, Error> {
        Task.delayed(byTimeInterval: uploadInterval, priority: priority) { [weak self] in
            await self?.flush()
        }
    }

    func cancelTimer() {
        timerTask?.cancel()
        timerTask = nil
    }
}

extension EventQueue {
    static func live(
        logger: LyticsLogger,
        configuration: LyticsConfiguration,
        upload: @escaping ([Request<DataUploadResponse>]) async -> Void
    ) -> EventQueue {
        EventQueue(
            logger: logger,
            maxQueueSize: configuration.maxQueueSize,
            uploadInterval: configuration.uploadInterval,
            requestBuilder: .live(apiKey: configuration.apiKey),
            upload: upload)
    }
}
