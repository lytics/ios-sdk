//
//  Mock.swift
//
//  Created by Mathew Gacy on 10/18/22.
//

@testable import Lytics
import AnyCodable
import Foundation

enum Mock {
    static let apiKey = "at.xxxx"

    static let consentEvent = ConsentEvent(
        identifiers: User1.identifiers,
        attributes: User1.attributes,
        consent: TestConsent.user1)

    static let event = Event(
        identifiers: User1.identifiers,
        properties: TestCart.user1)

    static let identityEvent = IdentityEvent(
        identifiers: TestIdentifiers.user1,
        attributes: TestAttributes.user1)

    static let request = Request<DataUploadResponse>(
        method: .post,
        url: url)

    static let url = URL(string: "https://api.lytics.io/collect/json/stream")!
}

extension Mock {
    enum Name: String {
        /// name_1.
        case one = "name_1"
        /// name_2.
        case two = "name_2"
        /// name_3.
        case three = "name_3"
    }

    enum Stream: String {
        /// stream_1.
        case one = "stream_1"
        /// stream_2.
        case two = "stream_2"
        /// stream_3.
        case three = "stream_3"
    }

    enum Timestamp: Millisecond {
        /// 1_666_000_000_000.
        case one = 1_666_000_000_000
        /// 1_666_000_001_000.
        case two = 1_666_000_001_000
        /// 1_666_000_002_500.
        case three = 1_666_000_002_500
    }

    static func name(_ value: Name) -> String {
        value.rawValue
    }

    static func stream(_ value: Stream) -> String {
        value.rawValue
    }

    static func timestamp(_ value: Timestamp) -> Millisecond {
        value.rawValue
    }
}

extension Mock {
    static func payload<E: Encodable>(
        stream: String = Mock.stream(.one),
        timestamp: Millisecond = Self.timestamp(.one),
        sessionDidStart: Int? = nil,
        name: String = Mock.name(.one),
        event: E
    ) -> Payload<E> {
        .init(
            stream: stream,
            timestamp: timestamp,
            sessionDidStart: sessionDidStart,
            name: name,
            event: event)
    }

    static func payloadDictionary(
        stream: String = Mock.stream(.one),
        timestamp: Millisecond = Self.timestamp(.one),
        sessionDidStart: Int? = nil,
        name: String? = Mock.name(.one)
    ) -> [String: Any] {
        var dict: [String: Any] = [
            "stream": stream,
            "_ts": timestamp,
        ]

        if let sessionDidStart {
            dict["_sesstart"] = sessionDidStart
        }

        if let name {
            dict["name"] = name
        }

        return dict
    }

    static func consentEventDictionary(
        payload: inout [String: Any],
        identifiers: [String: Any]? = nil,
        attributes: [String: Any]? = nil,
        consent: [String: Any]? = nil
    ) -> [String: Any] {
        payload["identifiers"] = identifiers
        payload["attributes"] = attributes
        payload["consent"] = consent
        return payload
    }

    static func eventDictionary(
        payload: inout [String: Any],
        identifiers: [String: Any]? = nil,
        properties: [String: Any]? = nil
    ) -> [String: Any] {
        payload["identifiers"] = identifiers
        payload["properties"] = properties
        return payload
    }

    static func identityEventDictionary(
        payload: inout [String: Any],
        identifiers: [String: Any]? = nil,
        attributes: [String: Any]? = nil
    ) -> [String: Any] {
        payload["identifiers"] = identifiers
        payload["attributes"] = attributes
        return payload
    }
}
