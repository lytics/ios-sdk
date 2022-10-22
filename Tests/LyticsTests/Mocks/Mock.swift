//
//  Mock.swift
//
//  Created by Mathew Gacy on 10/18/22.
//

@testable import Lytics
import AnyCodable
import Foundation

enum Mock {
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

    static let timestamp: Millisecond = 1666000000000
}

extension Mock {
    static func payload<E: Encodable>(
        stream: String = "stream",
        timestamp: Millisecond = Self.timestamp,
        sessionDidStart: Int? = nil,
        name: String = "name",
        event: E
    ) -> Payload<E> {
        .init(
            stream: stream,
            timestamp: timestamp,
            sessionDidStart: sessionDidStart,
            name: name,
            event: event)
    }
}
