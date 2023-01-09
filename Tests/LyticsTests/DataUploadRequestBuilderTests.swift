//
//  DataUploadRequestBuilderTests.swift
//
//  Created by Mathew Gacy on 10/17/22.
//

import AnyCodable
import Foundation
@testable import Lytics
import XCTest

final class DataUploadRequestBuilderTests: XCTestCase {
    func testEncodeEmpty() throws {
        let events: [String: [any StreamEvent]] = [:]

        let sut = DataUploadRequestBuilder.live(apiToken: User1.apiToken)
        let requests = try sut.requests(events)
        XCTAssert(requests.isEmpty)
    }

    func testEncodeSingle() throws {
        let events: [String: [any StreamEvent]] = [
            Stream.one: [
                Mock.payload(
                    stream: Stream.one,
                    timestamp: Timestamp.one,
                    sessionDidStart: 1,
                    name: Name.one,
                    event: IdentityEvent(
                        identifiers: User1.identifiers,
                        attributes: User1.attributes
                    )
                )
            ],
            Stream.two: [
                Mock.payload(
                    stream: Stream.two,
                    timestamp: Timestamp.two,
                    name: Name.two,
                    event: ConsentEvent(
                        identifiers: User1.identifiers,
                        consent: TestConsent.user1
                    )
                )
            ]
        ]

        let sut = DataUploadRequestBuilder.live(apiToken: User1.apiToken)
        let requests = try sut.requests(events)

        XCTAssertEqual(requests.count, 2)

        let first = try JSONSerialization.jsonObject(with: requests.first!.body!) as! [String: Any]
        let last = try JSONSerialization.jsonObject(with: requests.last!.body!) as! [String: Any]
        assertOnEvents(first: first, last: last)
    }

    func testEncodeMultiple() throws {
        let events: [String: [any StreamEvent]] = [
            Stream.one: [
                Mock.payload(
                    stream: Stream.one,
                    timestamp: Timestamp.one,
                    sessionDidStart: 1,
                    name: Name.one,
                    event: IdentityEvent(
                        identifiers: User1.identifiers,
                        attributes: User1.attributes
                    )
                ),
                Mock.payload(
                    stream: Stream.two,
                    timestamp: Timestamp.two,
                    name: Name.two,
                    event: ConsentEvent(
                        identifiers: User1.identifiers,
                        consent: TestConsent.user1
                    )
                )
            ]
        ]

        let sut = DataUploadRequestBuilder.live(apiToken: User1.apiToken)
        let requests = try sut.requests(events)

        XCTAssertEqual(requests.count, 1)
        let array = try JSONSerialization.jsonObject(with: requests.first!.body!) as! [[String: Any]]
        XCTAssertEqual(array.count, 2)

        let first = array.first!
        let last = array.last!
        assertOnEvents(first: first, last: last)
    }

    func testEnableSandbox() throws {
        let events: [String: [any StreamEvent]] = [
            Stream.one: [
                Mock.payload(
                    stream: Stream.one,
                    timestamp: Timestamp.one,
                    sessionDidStart: 1,
                    name: Name.one,
                    event: IdentityEvent(
                        identifiers: User1.identifiers,
                        attributes: User1.attributes
                    )
                )
            ]
        ]

        let sut = DataUploadRequestBuilder.live(apiToken: User1.apiToken, dryRun: true)
        let requests = try sut.requests(events)

        let dryRunParam = requests.first!.parameters?.first(where: { $0.name == "dryrun" })!
        XCTAssertEqual(dryRunParam?.value, "true")
    }

    func testDisableSandbox() throws {
        let events: [String: [any StreamEvent]] = [
            Stream.one: [
                Mock.payload(
                    stream: Stream.one,
                    timestamp: Timestamp.one,
                    sessionDidStart: 1,
                    name: Name.one,
                    event: IdentityEvent(
                        identifiers: User1.identifiers,
                        attributes: User1.attributes
                    )
                )
            ]
        ]

        let sut = DataUploadRequestBuilder.live(apiToken: User1.apiToken)
        let requests = try sut.requests(events)

        XCTAssertNil(requests.first!.parameters)
    }
}

// MARK: - Helpers
extension DataUploadRequestBuilderTests {
    func assertOnEvents(first: [String: Any], last: [String: Any]) {
        let firstName = first["name"] as! String

        if firstName == Name.one {
            assertOnIdentityEvent(first)
            assertOnConsentEvent(last)
        } else if firstName == Name.two {
            assertOnIdentityEvent(last)
            assertOnConsentEvent(first)
        } else {
            XCTFail("Request bodies do not match expectations")
        }
    }

    func assertOnIdentityEvent(_ object: [String: Any]) {
        XCTAssertEqual(object["name"] as! String, Name.one)

        XCTAssertEqual(object["_ts"] as! Int64, Timestamp.one)
        XCTAssertEqual(object["_sesstart"] as! Int, 1)

        let identifiers1 = object["identifiers"] as! [String: Any]
        XCTAssertEqual(identifiers1["email"] as! String, User1.email)
        XCTAssertEqual(identifiers1["userID"] as! Int, User1.userID)
        let nested1 = identifiers1["nested"] as! [String: Any]
        XCTAssertEqual(nested1["a"] as! Int, User1.a)
        XCTAssertEqual(nested1["b"] as! String, User1.b)

        let attributes = object["attributes"] as! [String: Any]
        XCTAssertEqual(attributes["firstName"] as! String, User1.firstName)
        XCTAssertEqual(attributes["titles"] as! [String], User1.titles)
    }

    func assertOnConsentEvent(_ object: [String: Any]) {
        XCTAssertEqual(object["name"] as! String, Name.two)

        XCTAssertEqual(object["_ts"] as! Int64, Timestamp.two)

        let identifiers2 = object["identifiers"] as! [String: Any]
        XCTAssertEqual(identifiers2["email"] as! String, User1.email)
        XCTAssertEqual(identifiers2["userID"] as! Int, User1.userID)
        let nested2 = identifiers2["nested"] as! [String: Any]
        XCTAssertEqual(nested2["a"] as! Int, User1.a)
        XCTAssertEqual(nested2["b"] as! String, User1.b)

        let consent = object["consent"] as! [String: Any]
        XCTAssertEqual(consent["document"] as! String, TestConsent.user1.document)
        XCTAssertEqual(consent["timestamp"] as! String, TestConsent.user1.timestamp)
        XCTAssertEqual(consent["consented"] as! Bool, TestConsent.user1.consented)
    }
}
