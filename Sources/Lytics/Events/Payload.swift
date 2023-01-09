//
//  Payload.swift
//
//  Created by Mathew Gacy on 10/20/22.
//

import Foundation

@usableFromInline
struct Payload<E: Encodable>: StreamEvent {
    var stream: String
    var timestamp: Millisecond
    var sessionDidStart: Int?
    var name: String?
    var event: E

    @usableFromInline
    init(
        stream: String,
        timestamp: Millisecond,
        sessionDidStart: Int? = nil,
        name: String? = nil,
        event: E
    ) {
        self.stream = stream
        self.timestamp = timestamp
        self.sessionDidStart = sessionDidStart
        self.name = name
        self.event = event
    }

    @usableFromInline
    init(
        stream: String,
        sessionTimestamp: (Millisecond, Int?),
        name: String? = nil,
        event: E
    ) {
        self.stream = stream
        self.timestamp = sessionTimestamp.0
        self.sessionDidStart = sessionTimestamp.1
        self.name = name
        self.event = event
    }

    @usableFromInline
    func encode(to encoder: Encoder) throws {
        var container: KeyedEncodingContainer<Payload<E>.CodingKeys> = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(timestamp, forKey: .timestamp)
        try container.encodeIfPresent(sessionDidStart, forKey: .sessionDidStart)
        try container.encodeIfPresent(name, forKey: .name)
        try event.encode(to: encoder)
    }

    private enum CodingKeys: String, CodingKey {
        case timestamp = "_ts"
        case sessionDidStart = "_sesstart"
        case name
    }
}
