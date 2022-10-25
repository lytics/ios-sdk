//
//  CodableRequestContainerTests.swift
//
//  Created by Mathew Gacy on 10/18/22.
//

@testable import Lytics
import AnyCodable
import XCTest

final class CodableRequestContainerTests: XCTestCase {
    let identityEvent = Mock.payload(
        stream: Mock.stream(.one),
        timestamp: Mock.timestamp(.one),
        sessionDidStart: 1,
        name: Mock.name(.one),
        event: IdentityEvent(
            identifiers: User1.identifiers,
            attributes: User1.attributes))

    var identityEventDictionary: [String: Any] {
        var payload = Mock.payloadDictionary(
            stream: Mock.stream(.one),
            timestamp: Mock.timestamp(.one),
            sessionDidStart: 1,
            name: Mock.name(.one))

        return Mock.identityEventDictionary(
            payload: &payload,
            identifiers: User1.anyIdentifiers,
            attributes: User1.anyAttributes)
    }

    let consentEvent = Mock.payload(
        stream: Mock.stream(.two),
        timestamp: Mock.timestamp(.two),
        name: Mock.name(.two),
        event: ConsentEvent(
            identifiers: User1.identifiers,
            consent: TestConsent.user1))

    var consentEventDictionary: [String: Any] {
        var payload = Mock.payloadDictionary(
            stream: Mock.stream(.two),
            timestamp: Mock.timestamp(.two),
            name: Mock.name(.two))

        return Mock.consentEventDictionary(
            payload: &payload,
            identifiers: User1.anyIdentifiers,
            consent: [
                "document": TestConsent.user1.document,
                "timestamp": TestConsent.user1.timestamp,
                "consented": TestConsent.user1.consented
            ])
    }

    var events: [String: [any StreamEvent]] {
        [
            Mock.stream(.one): [
                identityEvent
            ],
            Mock.stream(.two): [
                consentEvent
            ]
        ]
    }

    func testEncodeAndDecode() throws {
        let requestBuilder = DataUploadRequestBuilder.live(apiKey: Mock.apiKey)
        let wrappedRequests = try requestBuilder
            .requests(events)
            .map { Uploader.PendingRequest(request: $0) }

        // Encode
        let container = CodableRequestContainer(requests: wrappedRequests)
        let data = try JSONEncoder().encode(container)

        let string = String(decoding: data, as: UTF8.self)
        print("\(string)\n")

        // Decoded
        let decoded = try JSONDecoder().decode(CodableRequestContainer.self, from: data)
        XCTAssertEqual(decoded.requests.count, 2)

        let wrapper1 = decoded.requests.first! as! Uploader.PendingRequest<DataUploadResponse>
        let body1 = try JSONSerialization.jsonObject(with: wrapper1.request.body!) as! [String: Any]

        let wrapper2 = decoded.requests.last! as! Uploader.PendingRequest<DataUploadResponse>
        let body2 = try JSONSerialization.jsonObject(with: wrapper2.request.body!) as! [String: Any]

        switch wrapper1.request.url.lastPathComponent {
        case Mock.stream(.one):
            Assert.identityEventEquality(body1, expected: identityEventDictionary)
            Assert.consentEventEquality(body2, expected: consentEventDictionary)
        case Mock.stream(.two):
            Assert.identityEventEquality(body2, expected: identityEventDictionary)
            Assert.consentEventEquality(body1, expected: consentEventDictionary)
        default:
            XCTFail("Request URLs do not match expectations")
        }
    }
}
