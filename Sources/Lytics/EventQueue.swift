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
    private let encoder: JSONEncoder
    private let requestBuilder: RequestBuilder
    private var events: [any StreamEvent] = []

    var isEmpty: Bool {
        events.isEmpty
    }

    init(
        encoder: JSONEncoder = .init(),
        logger: LyticsLogger,
        maxQueueSize: Int,
        uploadInterval: TimeInterval,
        requestBuilder: RequestBuilder
    ) {
        self.encoder = encoder
        self.logger = logger
        self.maxQueueSize = maxQueueSize
        self.uploadInterval = uploadInterval
        self.requestBuilder = requestBuilder
    }

    /// Adds an event to the queue.
    /// - Parameter event: the event to add.
    func enqueue<E: StreamEvent>(_ event: E) {
        events.append(event)
    }

    func flush() {
    }
}

private extension EventQueue {
    func send() {
        guard events.isNotEmpty else {
            return
        }

        do {
            let requests = try requests(for: events)
            events = []
        } catch {
            logger.error(error.localizedDescription)
        }
    }

    func requests(for events: [any StreamEvent]) throws -> [Request<DataUploadResponse>]  {
        try events.reduce(into: [String: [any StreamEvent]]()) { streams, event in
            streams[event.stream, default: []].append(event)
        }.reduce(into: [Request<DataUploadResponse>]()) { requests, element in
            do {
                guard let value = element.value as? any Encodable else {
                    throw EncodingError.invalidValue(
                        element.value,
                        .init(codingPath: [], debugDescription: "\(type(of: element.value)) is not encodable."))
                }

                requests.append(
                    requestBuilder.dataUpload(
                        stream: element.key,
                        data: try encoder.encode(value)))
            }
        }
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
            uploadInterval: configuration.uploadInterval,
            requestBuilder: .live(apiKey: configuration.apiKey))
    }
}
