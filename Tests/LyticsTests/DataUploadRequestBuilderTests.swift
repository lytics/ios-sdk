//
//  DataUploadRequestBuilderTests.swift
//
//  Created by Mathew Gacy on 10/17/22.
//

@testable import Lytics
import AnyCodable
import Foundation
import XCTest

final class DataUploadRequestBuilderTests: XCTestCase {
    let stream1 = "stream_1"
    let stream2 = "stream_2"
    let name1 = "name_1"
    let name2 = "name_2"

    func testEncodeEmpty() throws {
        let events: [String: [any StreamEvent]] = [:]

        let sut = DataUploadRequestBuilder.live(apiKey: User1.apiKey)
        let requests = try sut.requests(events)
        XCTAssert(requests.isEmpty)
    }

    func testEncodeSingle() throws {
        let events: [String: [any StreamEvent]] = [
            stream1: [
                IdentityEvent(
                    stream: stream1,
                    name: name1,
                    identifiers: User1.identifiers,
                    attributes: User1.attributes)
            ],
            stream2: [
                ConsentEvent(
                   stream: stream2,
                   name: name2,
                   identifiers: User1.identifiers,
                   consent: TestConsent.user1)
            ]
        ]

        let sut = DataUploadRequestBuilder.live(apiKey: User1.apiKey)
        let requests = try sut.requests(events)

        XCTAssertEqual(requests.count, 2)

        // Stream 1
        let first = try JSONSerialization.jsonObject(with: requests.first!.body!) as! [String: Any]
        XCTAssertEqual(first["name"] as! String, name1)

        let identifiers1 = first["identifiers"] as! [String: Any]
        XCTAssertEqual(identifiers1["email"] as! String, User1.email)
        XCTAssertEqual(identifiers1["userID"] as! Int, User1.userID)
        let nested1 = identifiers1["nested"] as! [String: Any]
        XCTAssertEqual(nested1["a"] as! Int, User1.a)
        XCTAssertEqual(nested1["b"] as! String, User1.b)

        let attributes = first["attributes"] as! [String: Any]
        XCTAssertEqual(attributes["firstName"] as! String, User1.firstName)
        XCTAssertEqual(attributes["titles"] as! [String], User1.titles)

        // Stream 2
        let last = try JSONSerialization.jsonObject(with: requests.last!.body!) as! [String: Any]
        XCTAssertEqual(last["name"] as! String, name2)

        let identifiers2 = last["identifiers"] as! [String: Any]
        XCTAssertEqual(identifiers2["email"] as! String, User1.email)
        XCTAssertEqual(identifiers2["userID"] as! Int, User1.userID)
        let nested2 = identifiers2["nested"] as! [String: Any]
        XCTAssertEqual(nested2["a"] as! Int, User1.a)
        XCTAssertEqual(nested2["b"] as! String, User1.b)

        let consent = last["consent"] as! [String: Any]
        XCTAssertEqual(consent["document"] as! String, TestConsent.user1.document)
        XCTAssertEqual(consent["timestamp"] as! String, TestConsent.user1.timestamp)
        XCTAssertEqual(consent["consented"] as! Bool, TestConsent.user1.consented)
    }

    func testEncodeMultiple() throws {
        let events: [String: [any StreamEvent]] = [
            stream1: [
                IdentityEvent(
                    stream: stream1,
                    name: name1,
                    identifiers: User1.identifiers,
                    attributes: User1.attributes),
                ConsentEvent(
                   stream: stream2,
                   name: name2,
                   identifiers: User1.identifiers,
                   consent: TestConsent.user1)
            ]
        ]

        let sut = DataUploadRequestBuilder.live(apiKey: User1.apiKey)
        let requests = try sut.requests(events)

        XCTAssertEqual(requests.count, 1)
        let array = try JSONSerialization.jsonObject(with: requests.first!.body!) as! [[String: Any]]
        XCTAssertEqual(array.count, 2)

        // Identity Event
        let first = array.first!
        XCTAssertEqual(first["name"] as! String, name1)

        let identifiers1 = first["identifiers"] as! [String: Any]
        XCTAssertEqual(identifiers1["email"] as! String, User1.email)
        XCTAssertEqual(identifiers1["userID"] as! Int, User1.userID)
        let nested1 = identifiers1["nested"] as! [String: Any]
        XCTAssertEqual(nested1["a"] as! Int, User1.a)
        XCTAssertEqual(nested1["b"] as! String, User1.b)

        let attributes = first["attributes"] as! [String: Any]
        XCTAssertEqual(attributes["firstName"] as! String, User1.firstName)
        XCTAssertEqual(attributes["titles"] as! [String], User1.titles)

        // Consent Event
        let last = array.last!
        XCTAssertEqual(last["name"] as! String, name2)

        let identifiers2 = last["identifiers"] as! [String: Any]
        XCTAssertEqual(identifiers2["email"] as! String, User1.email)
        XCTAssertEqual(identifiers2["userID"] as! Int, User1.userID)
        let nested2 = identifiers2["nested"] as! [String: Any]
        XCTAssertEqual(nested2["a"] as! Int, User1.a)
        XCTAssertEqual(nested2["b"] as! String, User1.b)

        let consent = last["consent"] as! [String: Any]
        XCTAssertEqual(consent["document"] as! String, TestConsent.user1.document)
        XCTAssertEqual(consent["timestamp"] as! String, TestConsent.user1.timestamp)
        XCTAssertEqual(consent["consented"] as! Bool, TestConsent.user1.consented)
    }
}