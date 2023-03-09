//
//  CodableRequestContainerTests.swift
//
//  Created by Mathew Gacy on 10/18/22.
//

import AnyCodable
@testable import Lytics
import XCTest

final class CodableRequestContainerTests: XCTestCase {
    let identityEvent = Mock.payload(
        stream: Stream.one,
        timestamp: Timestamp.one,
        sessionDidStart: 1,
        name: Name.one,
        event: IdentityEvent(
            identifiers: User1.identifiers,
            attributes: User1.attributes
        )
    )

    var identityEventDictionary: [String: Any] {
        var payload = Mock.payloadDictionary(
            stream: Stream.one,
            timestamp: Timestamp.one,
            sessionDidStart: 1,
            name: Name.one
        )

        return Mock.identityEventDictionary(
            payload: &payload,
            identifiers: User1.anyIdentifiers,
            attributes: User1.anyAttributes
        )
    }

    let consentEvent = Mock.payload(
        stream: Stream.two,
        timestamp: Timestamp.two,
        name: Name.two,
        event: ConsentEvent(
            identifiers: User1.identifiers,
            consent: TestConsent.user1
        )
    )

    var consentEventDictionary: [String: Any] {
        var payload = Mock.payloadDictionary(
            stream: Stream.two,
            timestamp: Timestamp.two,
            name: Name.two
        )

        return Mock.consentEventDictionary(
            payload: &payload,
            identifiers: User1.anyIdentifiers,
            consent: [
                "document": TestConsent.user1.document,
                "timestamp": TestConsent.user1.timestamp,
                "consented": TestConsent.user1.consented
            ]
        )
    }

    var events: [String: [any StreamEvent]] {
        [
            Stream.one: [
                identityEvent
            ],
            Stream.two: [
                consentEvent
            ]
        ]
    }

    func testEncodeAndDecode() throws {
        let requestBuilder = DataUploadRequestBuilder.live(
            requestBuilder: .live(
                apiToken: Mock.apiToken,
                configuration: LyticsConfiguration()
            )
        )

        let wrappedRequests = try requestBuilder
            .requests(events)
            .map { Uploader.PendingRequest(request: $0) }

        // Encode
        let container = CodableRequestContainer(requests: wrappedRequests)
        let data = try JSONEncoder().encode(container)

        // Decoded
        let decoded = try JSONDecoder().decode(CodableRequestContainer.self, from: data)
        XCTAssertEqual(decoded.requests.count, 2)

        let wrapper1 = decoded.requests.first! as! Uploader.PendingRequest<DataUploadResponse>
        let body1 = try JSONSerialization.jsonObject(with: wrapper1.request.body!) as! [String: Any]

        let wrapper2 = decoded.requests.last! as! Uploader.PendingRequest<DataUploadResponse>
        let body2 = try JSONSerialization.jsonObject(with: wrapper2.request.body!) as! [String: Any]

        switch wrapper1.request.url.lastPathComponent {
        case Stream.one:
            Assert.identityEventEquality(body1, expected: identityEventDictionary)
            Assert.consentEventEquality(body2, expected: consentEventDictionary)
        case Stream.two:
            Assert.identityEventEquality(body2, expected: identityEventDictionary)
            Assert.consentEventEquality(body1, expected: consentEventDictionary)
        default:
            XCTFail("Request URLs do not match expectations")
        }
    }

    func testDecodeNotCodableData() {
        enum NotCodable {}

        let typeString = _mangledTypeName(NotCodable.self) ?? ""
        let invalidData = Data("[\"\(typeString)\",{}]".utf8)

        var thrownError: Error!
        XCTAssertThrowsError(try JSONDecoder().decode(CodableRequestContainer.self, from: invalidData)) {
            thrownError = $0
        }
        XCTAssertNotNil(thrownError as? DecodingError)
    }
}
