//
//  LyticsTests.swift
//
//  Created by Mathew Gacy on 9/12/22.
//

import AnyCodable
@testable import Lytics
import XCTest

final class LyticsTests: XCTestCase {
    let expectationTimeout: TimeInterval = 0.1

    let expectedAttributeDictionary = User1.attributes
    let expectedAttributes = TestAttributes.user1
    let expectedIdentifierDictionary = User1.identifiers
    let expectedIdentifiers = TestIdentifiers.user1
    let expectedName = "Name"
    let expectedStream = "Stream"
    let expectedTimestamp = Mock.millisecond

    var actualAttributeDictionary: [String: AnyCodable]!
    var actualAttributes: TestAttributes!
    var actualIdentifierDictionary: [String: AnyCodable]!
    var actualIdentifiers: TestIdentifiers!
    var actualName: String!
    var actualStream: String!
    var actualTimestamp: Millisecond!
    var actualUserUpdate: UserUpdate<TestIdentifiers, TestAttributes>!

    override func tearDown() {
        actualAttributeDictionary = nil
        actualAttributes = nil
        actualIdentifierDictionary = nil
        actualIdentifiers = nil
        actualName = nil
        actualStream = nil
        actualTimestamp = nil
        actualUserUpdate = nil
    }
}
// MARK: - Events - Track
extension LyticsTests {
    func testTrackUpdatesAndUploads() async {
        let expectedEvent = Event<TestCart>(
            identifiers: User1.identifiers,
            properties: .user1
        )

        // Dependencies

        let eventExpectation = expectation(description: "Event uploaded")
        var actualEvent: Event<TestCart>!
        let eventPipeline = EventPipelineMock(
            onEvent: { stream, timestamp, name, event in
                self.actualStream = stream
                self.actualTimestamp = timestamp
                self.actualName = name
                actualEvent = event as? Event<TestCart>
                eventExpectation.fulfill()
            }
        )

        let updateExpectation = expectation(description: "User updated")
        let userManager = UserManagerMock<TestIdentifiers, TestAttributes>(
            onUpdateIdentifiers: { identifiers in
                self.actualIdentifiers = identifiers
                updateExpectation.fulfill()
                return User1.anyIdentifiers
            }
        )

        let sut = Lytics(
            logger: .mock,
            dependencies: .mock(
                eventPipeline: eventPipeline,
                userManager: userManager
            )
        )

        sut.track(
            stream: expectedStream,
            name: expectedName,
            timestamp: expectedTimestamp,
            identifiers: expectedIdentifiers,
            properties: TestCart.user1
        )

        await waitForExpectations(timeout: expectationTimeout)

        XCTAssertEqual(actualStream, expectedStream)
        XCTAssertEqual(actualName, expectedName)
        XCTAssertEqual(actualTimestamp, expectedTimestamp)
        XCTAssertEqual(actualEvent, expectedEvent)
        XCTAssertEqual(actualIdentifiers, expectedIdentifiers)
    }
}

// MARK: - Events - Identify
extension LyticsTests {
    func testIdentifyUpdatesAndUploads() async {
        let expectedEvent = IdentityEvent<[String: AnyCodable], [String: AnyCodable]>(
            identifiers: User1.identifiers,
            attributes: User1.attributes
        )

        // Dependencies

        let eventExpectation = expectation(description: "Event uploaded")
        var actualEvent: IdentityEvent<[String: AnyCodable], [String: AnyCodable]>!
        let eventPipeline = EventPipelineMock(
            onEvent: { stream, timestamp, name, event in
                self.actualStream = stream
                self.actualTimestamp = timestamp
                self.actualName = name
                actualEvent = event as? IdentityEvent<[String: AnyCodable], [String: AnyCodable]>
                eventExpectation.fulfill()
            }
        )

        let updateExpectation = expectation(description: "User updated")
        let userManager = UserManagerMock<TestIdentifiers, TestAttributes>(
            onUpdate: { userUpdate in
                defer { updateExpectation.fulfill() }

                self.actualAttributes = userUpdate.attributes
                self.actualIdentifiers = userUpdate.identifiers
                return Mock.user
            }
        )

        let sut = Lytics(
            logger: .mock,
            dependencies: .mock(
                eventPipeline: eventPipeline,
                userManager: userManager
            )
        )

        sut.identify(
            stream: expectedStream,
            name: expectedName,
            timestamp: expectedTimestamp,
            identifiers: expectedIdentifiers,
            attributes: expectedAttributes,
            shouldSend: true
        )

        await waitForExpectations(timeout: expectationTimeout)

        XCTAssertEqual(actualStream, expectedStream)
        XCTAssertEqual(actualTimestamp, expectedTimestamp)
        XCTAssertEqual(actualName, expectedName)
        XCTAssertEqual(actualEvent, expectedEvent)
        XCTAssertEqual(actualAttributes, expectedAttributes)
        XCTAssertEqual(actualIdentifiers, expectedIdentifiers)
    }
}
