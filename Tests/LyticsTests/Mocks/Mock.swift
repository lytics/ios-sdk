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
        stream: "stream",
        name: "name",
        identifiers: User1.identifiers,
        attributes: User1.attributes,
        consent: TestConsent.user1)

    static let event = Event(
        stream: "stream",
        name: "name",
        identifiers: User1.identifiers,
        properties: TestCart.user1)

    static let identityEvent = IdentityEvent(
        stream: "stream",
        name: "name",
        identifiers: TestIdentifiers.user1,
        attributes: TestAttributes.user1)

    static let request = Request<DataUploadResponse>(
        method: .post,
        url: url)

    static let url = URL(string: "https://api.lytics.io/collect/json/stream")!
}

extension Mock {
    static func consentEvent(
        stream: String,
        name: String = "name"
    ) -> ConsentEvent<TestConsent> {
        .init(
            stream: stream,
            name: name,
            identifiers: User1.identifiers,
            attributes: User1.attributes,
            consent: TestConsent.user1)
    }

    static func event(
        stream: String,
        name: String = "name"
    ) -> Event<TestCart> {
        .init(
            stream: stream,
            name: name,
            identifiers: User1.identifiers,
            properties: TestCart.user1)
    }

    static func identityEvent(
        stream: String,
        name: String = "name"
    ) -> IdentityEvent<TestIdentifiers, TestAttributes> {
        .init(
            stream: stream,
            name: name,
            identifiers: TestIdentifiers.user1,
            attributes: TestAttributes.user1)
    }
}
