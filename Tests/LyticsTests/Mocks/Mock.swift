//
//  Mock.swift
//
//  Created by Mathew Gacy on 10/18/22.
//

import AnyCodable
import Foundation
@testable import Lytics

enum Mock {
    static let apiToken = "at.xxxx"

    static let consentEvent = ConsentEvent(
        identifiers: User1.identifiers,
        attributes: User1.attributes,
        consent: TestConsent.user1
    )

    static let dataUploadResponse = DataUploadResponse(
        status: 200,
        message: "Message",
        data: .init(
            messageCount: 1,
            rejectedCount: 0,
            contentType: nil,
            dropErrors: nil,
            dryrun: nil,
            timestampField: nil,
            filename: nil
        )
    )

    static let event = Event(
        identifiers: User1.identifiers,
        properties: TestCart.user1
    )

    static let identityEvent = IdentityEvent(
        identifiers: TestIdentifiers.user1,
        attributes: TestAttributes.user1
    )

    static let request = Request<DataUploadResponse>(
        method: .post,
        url: url
    )

    static let uuidString = "AAAAAAAA-AAAA-AAAA-AAAA-AAAAAAAAAAAA"

    static let url = URL(string: "https://api.lytics.io/collect/json/stream")!

    static var uuid: UUID {
        .init(uuidString: uuidString)!
    }
}

extension Mock {
    static func containerJSON<R: Codable>(response: R.Type, idStrings: [String]) -> String {
        func request(_ idString: String) -> String {
            """
            "{\\"id\\":\\"\(idString)\\",\\"request\\":{\\"url\\":\\"https:\\\\\\/\\\\\\/api.lytics.io\\\\\\/collect\\\\\\/json\\\\\\/stream\\",\\"method\\":\\"POST\\"}}"
            """
        }

        let typeString = _mangledTypeName(Uploader.PendingRequest<R>.self) ?? ""
        let elements = idStrings
            .map { "\"\(typeString)\",\(request($0))" }
            .joined(separator: ",")

        return "[\(elements)]"
    }

    static func httpResponse(
        _ statusCode: Int = 200,
        headerFields: [String: String]? = nil
    ) -> HTTPURLResponse {
        .init(
            url: url,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: headerFields
        )!
    }

    static func payload<E: Encodable>(
        stream: String = Stream.one,
        timestamp: Millisecond = Timestamp.one,
        sessionDidStart: Int? = nil,
        name: String = Name.one,
        event: E
    ) -> Payload<E> {
        .init(
            stream: stream,
            timestamp: timestamp,
            sessionDidStart: sessionDidStart,
            name: name,
            event: event
        )
    }

    static func payloadDictionary(
        stream: String = Stream.one,
        timestamp: Millisecond = Timestamp.one,
        sessionDidStart: Int? = nil,
        name: String? = Name.one
    ) -> [String: Any] {
        var dict: [String: Any] = [
            "stream": stream,
            "_ts": timestamp
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
