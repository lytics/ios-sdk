//
//  LyticsTests.swift
//
//  Created by Mathew Gacy on 9/12/22.
//

import AnyCodable
@testable import Lytics
import os.log
import XCTest

final class LyticsTests: XCTestCase {
    let expectationTimeout: TimeInterval = 0.5

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

// MARK: - Properties
extension LyticsTests {
    func testGetIsOptedIn() async {
        let expected = true
        let eventPipeline = EventPipelineMock(isOptedIn: expected)

        let sut = Lytics(
            logger: .mock,
            dependencies: .test(
                eventPipeline: eventPipeline
            )
        )

        let actual = sut.isOptedIn
        XCTAssertEqual(actual, expected)
    }

    func testGetIsOptedInBeforeStarting() {
        let failureExpectation = expectation(description: "Not started failure")
        let sut = Lytics(assertionFailure: { _, _, _ in failureExpectation.fulfill() }, logger: .mock)

        _ = sut.isOptedIn
        waitForExpectations(timeout: expectationTimeout)
    }

    func testGetIsIDFAEnabledWhenEnabled() async {
        let expectedEnabled = true

        let idfaExpectation = expectation(description: "IDFA fetched")
        let appTrackingTransparency = AppTrackingTransparency.test(
            idfa: {
                defer { idfaExpectation.fulfill() }
                return "1234"
            }
        )

        let sut = Lytics(
            logger: .mock,
            dependencies: .test(appTrackingTransparency: appTrackingTransparency)
        )

        let actualEnabled = sut.isIDFAEnabled

        await waitForExpectations(timeout: expectationTimeout)

        XCTAssertEqual(actualEnabled, expectedEnabled)
    }

    func testGetIsIDFAEnabledWhenDisabled() async {
        let expectedEnabled = false

        let idfaExpectation = expectation(description: "IDFA fetched")
        let appTrackingTransparency = AppTrackingTransparency.test(
            idfa: {
                defer { idfaExpectation.fulfill() }
                return nil
            }
        )

        let sut = Lytics(
            logger: .mock,
            dependencies: .test(appTrackingTransparency: appTrackingTransparency)
        )

        let actualEnabled = sut.isIDFAEnabled

        await waitForExpectations(timeout: expectationTimeout)

        XCTAssertEqual(actualEnabled, expectedEnabled)
    }

    func testGetIsIDFAEnabledBeforeStarting() {
        let failureExpectation = expectation(description: "Not started failure")
        let sut = Lytics(assertionFailure: { _, _, _ in failureExpectation.fulfill() }, logger: .mock)

        _ = sut.isIDFAEnabled
        waitForExpectations(timeout: expectationTimeout)
    }

    func testGetUser() async {
        let expectedUser = Mock.user

        let userManager = UserManagerMock<Never, Never>(
            user: expectedUser
        )

        let sut = Lytics(
            logger: .mock,
            dependencies: .test(
                userManager: userManager
            )
        )

        let actualUser = await sut.user
        XCTAssertEqual(actualUser, expectedUser)
    }

    func testGetUserBeforeStarting() async {
        let failureExpectation = expectation(description: "Not started failure")
        let sut = Lytics(assertionFailure: { _, _, _ in failureExpectation.fulfill() }, logger: .mock)

        await _ = sut.user
        await waitForExpectations(timeout: expectationTimeout)
    }

    func testHasStartedAfterStarting() {
        let sut = Lytics()
        sut.start(apiToken: Mock.apiToken)
        XCTAssertEqual(sut.hasStarted, true)
    }
}

// MARK: - Events - Track
extension LyticsTests {
    func testTrackUpdatesAndUploads_AllArgs() async {
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
            dependencies: .test(
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

    func testTrackUpdatesAndUploads_4Args() async {
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

        let userManager = UserManagerMock<TestIdentifiers, TestAttributes>(
            identifiers: User1.anyIdentifiers
        )

        let sut = Lytics(
            logger: .mock,
            dependencies: .test(
                eventPipeline: eventPipeline,
                userManager: userManager
            )
        )

        sut.track(
            stream: expectedStream,
            name: expectedName,
            timestamp: expectedTimestamp,
            properties: TestCart.user1
        )

        await waitForExpectations(timeout: expectationTimeout)

        XCTAssertEqual(actualStream, expectedStream)
        XCTAssertEqual(actualName, expectedName)
        XCTAssertEqual(actualTimestamp, expectedTimestamp)
        XCTAssertEqual(actualEvent, expectedEvent)
    }

    func testTrackUpdatesAndUploads_3Args() async {
        let expectedEvent = Event<Never>(
            identifiers: User1.identifiers,
            properties: nil
        )

        // Dependencies

        let eventExpectation = expectation(description: "Event uploaded")
        var actualEvent: Event<Never>!
        let eventPipeline = EventPipelineMock(
            onEvent: { stream, timestamp, name, event in
                self.actualStream = stream
                self.actualTimestamp = timestamp
                self.actualName = name
                actualEvent = event as? Event<Never>
                eventExpectation.fulfill()
            }
        )

        let userManager = UserManagerMock<TestIdentifiers, TestAttributes>(
            identifiers: User1.anyIdentifiers
        )

        let sut = Lytics(
            logger: .mock,
            dependencies: .test(
                eventPipeline: eventPipeline,
                userManager: userManager
            )
        )

        sut.track(
            stream: expectedStream,
            name: expectedName,
            timestamp: expectedTimestamp
        )

        await waitForExpectations(timeout: expectationTimeout)

        XCTAssertEqual(actualStream, expectedStream)
        XCTAssertEqual(actualName, expectedName)
        XCTAssertEqual(actualTimestamp, expectedTimestamp)
        XCTAssertEqual(actualEvent, expectedEvent)
    }
}

// MARK: - Events - Identify
extension LyticsTests {
    func testIdentifyUpdatesAndUploads_AllArgs() async {
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
            dependencies: .test(
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

    func testIdentifyUpdatesAndUploads_5Args() async {
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
        let userManager = UserManagerMock<TestIdentifiers, Never>(
            onUpdate: { userUpdate in
                defer { updateExpectation.fulfill() }

                self.actualIdentifiers = userUpdate.identifiers
                return Mock.user
            }
        )

        let sut = Lytics(
            logger: .mock,
            dependencies: .test(
                eventPipeline: eventPipeline,
                userManager: userManager
            )
        )

        sut.identify(
            stream: expectedStream,
            name: expectedName,
            timestamp: expectedTimestamp,
            identifiers: expectedIdentifiers,
            shouldSend: true
        )

        await waitForExpectations(timeout: expectationTimeout)

        XCTAssertEqual(actualStream, expectedStream)
        XCTAssertEqual(actualTimestamp, expectedTimestamp)
        XCTAssertEqual(actualName, expectedName)
        XCTAssertEqual(actualEvent, expectedEvent)
        XCTAssertEqual(actualIdentifiers, expectedIdentifiers)
    }
}

// MARK: - Events - Consent
extension LyticsTests {
    func testConsentUpdatesAndUploads_AllArgs() async {
        let expectedEvent = ConsentEvent<TestConsent>(
            identifiers: User1.identifiers,
            attributes: User1.attributes,
            consent: .user1
        )

        // Dependencies

        let eventExpectation = expectation(description: "Event uploaded")
        var actualEvent: ConsentEvent<TestConsent>!
        let eventPipeline = EventPipelineMock(
            onEvent: { stream, timestamp, name, event in
                self.actualStream = stream
                self.actualTimestamp = timestamp
                self.actualName = name
                actualEvent = event as? ConsentEvent<TestConsent>
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
            dependencies: .test(
                eventPipeline: eventPipeline,
                userManager: userManager
            )
        )

        sut.consent(
            stream: expectedStream,
            name: expectedName,
            timestamp: expectedTimestamp,
            identifiers: expectedIdentifiers,
            attributes: expectedAttributes,
            consent: TestConsent.user1,
            shouldSend: true
        )

        await waitForExpectations(timeout: expectationTimeout)

        XCTAssertEqual(actualStream, expectedStream)
        XCTAssertEqual(actualName, expectedName)
        XCTAssertEqual(actualTimestamp, expectedTimestamp)
        XCTAssertEqual(actualEvent, expectedEvent)
        XCTAssertEqual(actualAttributes, expectedAttributes)
        XCTAssertEqual(actualIdentifiers, expectedIdentifiers)
    }

    func testConsentUpdatesAndUploads_6Args() async {
        let expectedEvent = ConsentEvent<TestConsent>(
            identifiers: User1.identifiers,
            attributes: User1.attributes,
            consent: .user1
        )

        // Dependencies

        let eventExpectation = expectation(description: "Event uploaded")
        var actualEvent: ConsentEvent<TestConsent>!
        let eventPipeline = EventPipelineMock(
            onEvent: { stream, timestamp, name, event in
                self.actualStream = stream
                self.actualTimestamp = timestamp
                self.actualName = name
                actualEvent = event as? ConsentEvent<TestConsent>
                eventExpectation.fulfill()
            }
        )

        let updateExpectation = expectation(description: "User updated")
        let userManager = UserManagerMock<Never, TestAttributes>(
            onUpdate: { userUpdate in
                defer { updateExpectation.fulfill() }

                self.actualAttributes = userUpdate.attributes
                return Mock.user
            }
        )

        let sut = Lytics(
            logger: .mock,
            dependencies: .test(
                eventPipeline: eventPipeline,
                userManager: userManager
            )
        )

        sut.consent(
            stream: expectedStream,
            name: expectedName,
            timestamp: expectedTimestamp,
            attributes: expectedAttributes,
            consent: TestConsent.user1,
            shouldSend: true
        )

        await waitForExpectations(timeout: expectationTimeout)

        XCTAssertEqual(actualStream, expectedStream)
        XCTAssertEqual(actualName, expectedName)
        XCTAssertEqual(actualTimestamp, expectedTimestamp)
        XCTAssertEqual(actualEvent, expectedEvent)
        XCTAssertEqual(actualAttributes, expectedAttributes)
    }

    func testConsentUpdatesAndUploads_5Args() async {
        let expectedEvent = ConsentEvent<TestConsent>(
            identifiers: User1.identifiers,
            attributes: User1.attributes,
            consent: .user1
        )

        // Dependencies

        let eventExpectation = expectation(description: "Event uploaded")
        var actualEvent: ConsentEvent<TestConsent>!
        let eventPipeline = EventPipelineMock(
            onEvent: { stream, timestamp, name, event in
                self.actualStream = stream
                self.actualTimestamp = timestamp
                self.actualName = name
                actualEvent = event as? ConsentEvent<TestConsent>
                eventExpectation.fulfill()
            }
        )

        let userManager = UserManagerMock<Never, Never>(
            user: Mock.user
        )

        let sut = Lytics(
            logger: .mock,
            dependencies: .test(
                eventPipeline: eventPipeline,
                userManager: userManager
            )
        )

        sut.consent(
            stream: expectedStream,
            name: expectedName,
            timestamp: expectedTimestamp,
            consent: TestConsent.user1,
            shouldSend: true
        )

        await waitForExpectations(timeout: expectationTimeout)

        XCTAssertEqual(actualStream, expectedStream)
        XCTAssertEqual(actualName, expectedName)
        XCTAssertEqual(actualTimestamp, expectedTimestamp)
        XCTAssertEqual(actualEvent, expectedEvent)
    }
}

// MARK: - Events - Screen
extension LyticsTests {
    func testScreenUpdatesAndUploads_AllArgs() async {
        let expectedEvent = ScreenEvent<TestCart>(
            device: Device(),
            identifiers: User1.identifiers,
            properties: .user1
        )

        // Dependencies

        let eventExpectation = expectation(description: "Event uploaded")
        var actualEvent: ScreenEvent<TestCart>!
        let eventPipeline = EventPipelineMock(
            onEvent: { stream, timestamp, name, event in
                self.actualStream = stream
                self.actualTimestamp = timestamp
                self.actualName = name
                actualEvent = event as? ScreenEvent<TestCart>
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
            dependencies: .test(
                eventPipeline: eventPipeline,
                userManager: userManager
            )
        )

        sut.screen(
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

    func testScreenUpdatesAndUploads_4Args() async {
        let expectedEvent = ScreenEvent<TestCart>(
            device: Device(),
            identifiers: User1.identifiers,
            properties: .user1
        )

        // Dependencies

        let eventExpectation = expectation(description: "Event uploaded")
        var actualEvent: ScreenEvent<TestCart>!
        let eventPipeline = EventPipelineMock(
            onEvent: { stream, timestamp, name, event in
                self.actualStream = stream
                self.actualTimestamp = timestamp
                self.actualName = name
                actualEvent = event as? ScreenEvent<TestCart>
                eventExpectation.fulfill()
            }
        )

        let userManager = UserManagerMock<TestIdentifiers, TestAttributes>(
            identifiers: User1.anyIdentifiers
        )

        let sut = Lytics(
            logger: .mock,
            dependencies: .test(
                eventPipeline: eventPipeline,
                userManager: userManager
            )
        )

        sut.screen(
            stream: expectedStream,
            name: expectedName,
            timestamp: expectedTimestamp,
            properties: TestCart.user1
        )

        await waitForExpectations(timeout: expectationTimeout)

        XCTAssertEqual(actualStream, expectedStream)
        XCTAssertEqual(actualName, expectedName)
        XCTAssertEqual(actualTimestamp, expectedTimestamp)
        XCTAssertEqual(actualEvent, expectedEvent)
    }
}

// MARK: - Event Helper Methods
extension LyticsTests {
    func testUpdateUserHandlesError() async {
        let expectedLogLevel = OSLogType.error

        var actualLogLevel: OSLogType!
        let loggerExpectation = expectation(description: "Error logged")
        let logger = LyticsLogger.test(
            log: { level, _, _, _, _ in
                actualLogLevel = level
                loggerExpectation.fulfill()
            }
        )

        let userManager = UserManagerMock<TestIdentifiers, TestAttributes>(
            onApply: { _ in throw TestError(message: "Error") }
        )

        let sut = Lytics(
            logger: logger,
            dependencies: .test(userManager: userManager)
        )

        sut.updateUser(with: UserUpdate(identifiers: TestIdentifiers.user1, attributes: TestAttributes.user1))

        await waitForExpectations(timeout: expectationTimeout)
        XCTAssertEqual(actualLogLevel, expectedLogLevel)
    }

    func testtestUpdateUserBeforeStarting() {
        let failureExpectation = expectation(description: "Not started failure")

        let sut = Lytics(assertionFailure: { _, _, _ in failureExpectation.fulfill() }, logger: .mock)

        sut.updateUser(with: UserUpdate(identifiers: TestIdentifiers.user1, attributes: TestAttributes.user1))

        waitForExpectations(timeout: expectationTimeout)
    }

    func testUpdateIdentifiersAndUploadHandlesError() async {
        let expectedLogLevel = OSLogType.error
        let expectedEvent = Event<TestCart>(identifiers: [:], properties: .user1)

        var actualLogLevel: OSLogType!
        let loggerExpectation = expectation(description: "Error logged")
        let logger = LyticsLogger.test(
            log: { level, _, _, _, _ in
                actualLogLevel = level
                loggerExpectation.fulfill()
            }
        )

        let eventExpectation = expectation(description: "Event uploaded")
        var actualEvent: Event<TestCart>!
        let eventPipeline = EventPipelineMock(
            onEvent: { _, _, _, event in
                actualEvent = event as? Event<TestCart>
                eventExpectation.fulfill()
            }
        )

        let userManager = UserManagerMock<TestIdentifiers, TestAttributes>(
            onUpdateIdentifiers: { _ in throw TestError(message: "Error") }
        )

        let sut = Lytics(
            logger: logger,
            dependencies: .test(
                eventPipeline: eventPipeline,
                userManager: userManager
            )
        )

        sut.updateIdentifiersAndUpload(
            stream: expectedStream,
            name: expectedName,
            timestamp: Mock.millisecond,
            identifiers: TestIdentifiers.user1
        ) { eventIdentifiers in
            Event<TestCart>(identifiers: eventIdentifiers, properties: .user1)
        }

        await waitForExpectations(timeout: expectationTimeout)
        XCTAssertEqual(actualLogLevel, expectedLogLevel)
        XCTAssertEqual(actualEvent, expectedEvent)
    }

    func testUpdateIdentifiersAndUploadBeforeStarting() {
        let failureExpectation = expectation(description: "Not started failure")

        let sut = Lytics(assertionFailure: { _, _, _ in failureExpectation.fulfill() }, logger: .mock)

        sut.updateIdentifiersAndUpload(
            stream: expectedStream,
            name: expectedName,
            timestamp: Mock.millisecond,
            identifiers: TestIdentifiers.user1
        ) { eventIdentifiers in
            Event<TestCart>(identifiers: eventIdentifiers, properties: .user1)
        }

        waitForExpectations(timeout: expectationTimeout)
    }

    func testUpdateUserAndUploadHandlesError() async {
        let expectedLogLevel = OSLogType.error

        var actualLogLevel: OSLogType!
        let loggerExpectation = expectation(description: "Error logged")
        let logger = LyticsLogger.test(
            log: { level, _, _, _, _ in
                actualLogLevel = level
                loggerExpectation.fulfill()
            }
        )

        let userManager = UserManagerMock<TestIdentifiers, TestAttributes>(
            onUpdate: { _ in throw TestError(message: "Error") }
        )

        let sut = Lytics(
            logger: logger,
            dependencies: .test(userManager: userManager)
        )

        let userUpdate = UserUpdate(identifiers: TestIdentifiers.user1, attributes: TestAttributes.user1)

        sut.updateUserAndUpload(
            stream: expectedStream,
            name: expectedName,
            timestamp: Mock.millisecond,
            userUpdate: userUpdate
        ) { user in
            Event<TestCart>(identifiers: user.identifiers, properties: .user1)
        }

        await waitForExpectations(timeout: expectationTimeout)
        XCTAssertEqual(actualLogLevel, expectedLogLevel)
    }

    func testUpdateUserAndUploadBeforeStarting() {
        let failureExpectation = expectation(description: "Not started failure")

        let sut = Lytics(assertionFailure: { _, _, _ in failureExpectation.fulfill() }, logger: .mock)

        sut.updateUserAndUpload(
            stream: expectedStream,
            name: expectedName,
            timestamp: Mock.millisecond,
            userUpdate: UserUpdate(identifiers: TestIdentifiers.user1, attributes: TestAttributes.user1)
        ) { user in
            Event<TestCart>(identifiers: user.identifiers, properties: .user1)
        }

        waitForExpectations(timeout: expectationTimeout)
    }
}

// MARK: - Personalization
extension LyticsTests {
    func testGetProfile() async throws {
        let expectedTable = "table"
        let expectedIdentifierName = "name"
        let expectedIdentifierValue = "value"

        let expectedUser = LyticsUser(
            identifiers: [expectedIdentifierName: AnyCodable(expectedIdentifierValue)],
            profile: Mock.entity.data
        )

        let loaderExpectation = expectation(description: "Loader called")
        var actualTable: String!
        var actualIdentifierName: String!
        var actualIdentifierValue: String!
        let loader = Loader.test(
            entity: { table, entityIdentifier in
                defer { loaderExpectation.fulfill() }

                actualTable = table
                actualIdentifierName = entityIdentifier.name
                actualIdentifierValue = entityIdentifier.value

                return Mock.entity
            })

        let userManager = UserManagerMock<Never, Never>(
            user: LyticsUser(identifiers: [expectedIdentifierName: expectedIdentifierValue])
        )

        let sut = Lytics(
            logger: .mock,
            dependencies: .test(
                configuration: .init(
                    primaryIdentityKey: expectedIdentifierName,
                    defaultTable: expectedTable
                ),
                userManager: userManager,
                loader: loader
            )
        )

        let actualUser = try await sut.getProfile()

        await waitForExpectations(timeout: expectationTimeout)

        XCTAssertEqual(actualUser, expectedUser)
        XCTAssertEqual(actualTable, expectedTable)
        XCTAssertEqual(actualIdentifierName, expectedIdentifierName)
        XCTAssertEqual(actualIdentifierValue, expectedIdentifierValue)
    }

    func testGetProfileWithCustomIdentifier() async throws {
        let expectedTable = "table"
        let expectedIdentifierName = "custom_name"
        let expectedIdentifierValue = "custom_value"

        let expectedUser = LyticsUser(
            identifiers: [expectedIdentifierName: AnyCodable(expectedIdentifierValue)],
            profile: Mock.entity.data
        )

        let loaderExpectation = expectation(description: "Loader called")
        var actualTable: String!
        var actualIdentifierName: String!
        var actualIdentifierValue: String!
        let loader = Loader.test(
            entity: { table, entityIdentifier in
                defer { loaderExpectation.fulfill() }

                actualTable = table
                actualIdentifierName = entityIdentifier.name
                actualIdentifierValue = entityIdentifier.value

                return Mock.entity
            })

        let userManager = UserManagerMock<Never, Never>(
            user: LyticsUser(identifiers: [expectedIdentifierName: expectedIdentifierValue])
        )

        let sut = Lytics(
            logger: .mock,
            dependencies: .test(
                configuration: .init(defaultTable: expectedTable),
                userManager: userManager,
                loader: loader
            )
        )

        let actualUser = try await sut.getProfile(
            EntityIdentifier(
                name: expectedIdentifierName,
                value: expectedIdentifierValue
            )
        )

        await waitForExpectations(timeout: expectationTimeout)

        XCTAssertEqual(actualUser, expectedUser)
        XCTAssertEqual(actualTable, expectedTable)
        XCTAssertEqual(actualIdentifierName, expectedIdentifierName)
        XCTAssertEqual(actualIdentifierValue, expectedIdentifierValue)
    }

    func testGetProfileThrowsIfMissingIdentifier() async {
        let userManager = UserManagerMock<Never, Never>(
            user: LyticsUser(identifiers: ["anonymousID": "1234"])
        )

        let sut = Lytics(
            logger: .mock,
            dependencies: .test(
                configuration: .init(),
                userManager: userManager
            )
        )

        let errorExpectation = expectation(description: "Error thrown")
        do {
            _ = try await sut.getProfile()
        } catch {
            errorExpectation.fulfill()
        }

        await waitForExpectations(timeout: expectationTimeout)
    }

    func testGetProfileBeforeStarting() async {
        let failureExpectation = expectation(description: "Not started failure")

        let sut = Lytics(assertionFailure: { _, _, _ in failureExpectation.fulfill() }, logger: .mock)

        let errorExpectation = expectation(description: "Error thrown")
        do {
            _ = try await sut.getProfile()
        } catch {
            errorExpectation.fulfill()
        }

        await waitForExpectations(timeout: expectationTimeout)
    }
}

// MARK: - App Events
extension LyticsTests {
    func testUploadContinueUserActivity() async {
        let activityType = "com.lytics.activity"
        let keywords = Set(["key", "word"])
        let referrerURL = URL(string: "https://example.com")!
        let userInfoKeys = Set(["user", "info"])
        let targetContentIdentifier = "identifier"
        let title = "title"
        let userInfo = ["user": "info"]
        let webpageURL = URL(string: "https://lytics.com")!

        let expectedEvent = UserActivityEvent(
            activityType: activityType,
            keywords: keywords,
            referrerURL: referrerURL,
            requiredUserInfoKeys: userInfoKeys,
            targetContentIdentifier: targetContentIdentifier,
            title: title,
            userInfo: ["user": "info"],
            webpageURL: webpageURL,
            identifiers: User1.identifiers
        )

        let userActivity = NSUserActivity(activityType: activityType)
        userActivity.keywords = keywords
        userActivity.referrerURL = referrerURL
        userActivity.requiredUserInfoKeys = userInfoKeys
        userActivity.targetContentIdentifier = targetContentIdentifier
        userActivity.title = title
        userActivity.userInfo = userInfo
        userActivity.webpageURL = webpageURL

        // Dependencies

        let eventExpectation = expectation(description: "Event uploaded")
        var actualEvent: UserActivityEvent!
        let eventPipeline = EventPipelineMock(
            onEvent: { stream, timestamp, name, event in
                self.actualStream = stream
                self.actualTimestamp = timestamp
                self.actualName = name
                actualEvent = event as? UserActivityEvent
                eventExpectation.fulfill()
            }
        )

        let userManager = UserManagerMock<Never, Never>(identifiers: User1.anyIdentifiers)

        let sut = Lytics(
            logger: .mock,
            dependencies: .test(
                configuration: .init(defaultStream: expectedStream),
                eventPipeline: eventPipeline,
                timestampProvider: { self.expectedTimestamp },
                userManager: userManager
            )
        )

        sut.continueUserActivity(userActivity, stream: expectedStream)

        await waitForExpectations(timeout: expectationTimeout)

        XCTAssertEqual(actualStream, expectedStream)
        XCTAssertEqual(actualName, "Deep Link")
        XCTAssertEqual(actualTimestamp, expectedTimestamp)
        XCTAssertEqual(actualEvent, expectedEvent)
    }

    func testUploadOpenURL() async {
        let expectedURL = URL(string: "https://example.com/foo")!

        let expectedEvent = URLEvent(
            url: expectedURL,
            options: ["UIApplicationOpenURLOptionsSourceApplicationKey": "bar.foo"],
            identifiers: User1.identifiers
        )

        let options: [UIApplication.OpenURLOptionsKey: Any] = [
            .sourceApplication: "bar.foo"
        ]

        // Dependencies

        let eventExpectation = expectation(description: "Event uploaded")
        var actualEvent: URLEvent!
        let eventPipeline = EventPipelineMock(
            onEvent: { stream, timestamp, name, event in
                self.actualStream = stream
                self.actualTimestamp = timestamp
                self.actualName = name
                actualEvent = event as? URLEvent
                eventExpectation.fulfill()
            }
        )

        let userManager = UserManagerMock<Never, Never>(identifiers: User1.anyIdentifiers)

        let sut = Lytics(
            logger: .mock,
            dependencies: .test(
                configuration: .init(defaultStream: expectedStream),
                eventPipeline: eventPipeline,
                timestampProvider: { self.expectedTimestamp },
                userManager: userManager
            )
        )

        sut.openURL(expectedURL, options: options, stream: expectedStream)

        await waitForExpectations(timeout: expectationTimeout)

        XCTAssertEqual(actualStream, expectedStream)
        XCTAssertEqual(actualName, "URL")
        XCTAssertEqual(actualTimestamp, expectedTimestamp)
        XCTAssertEqual(actualEvent, expectedEvent)
    }

    func testUploadShortcutItem() async {
        let title = "title"
        let subtitle = "subtitle"
        let type = "shortcut_type"

        let expectedEvent = ShortcutEvent(
            localizedTitle: title,
            localizedSubtitle: subtitle,
            type: type,
            userInfo: ["user": "info"],
            identifiers: User1.identifiers
        )

        let shortcutItem = UIApplicationShortcutItem(
            type: type,
            localizedTitle: title,
            localizedSubtitle: subtitle,
            icon: nil,
            userInfo: ["user": NSString(string: "info")]
        )

        // Dependencies

        let eventExpectation = expectation(description: "Event uploaded")
        var actualEvent: ShortcutEvent!
        let eventPipeline = EventPipelineMock(
            onEvent: { stream, timestamp, name, event in
                self.actualStream = stream
                self.actualTimestamp = timestamp
                self.actualName = name
                actualEvent = event as? ShortcutEvent
                eventExpectation.fulfill()
            }
        )

        let userManager = UserManagerMock<Never, Never>(identifiers: User1.anyIdentifiers)

        let sut = Lytics(
            logger: .mock,
            dependencies: .test(
                configuration: .init(defaultStream: expectedStream),
                eventPipeline: eventPipeline,
                timestampProvider: { self.expectedTimestamp },
                userManager: userManager
            )
        )

        sut.shortcutItem(shortcutItem, stream: expectedStream)

        await waitForExpectations(timeout: expectationTimeout)

        XCTAssertEqual(actualStream, expectedStream)
        XCTAssertEqual(actualName, "Shortcut")
        XCTAssertEqual(actualTimestamp, expectedTimestamp)
        XCTAssertEqual(actualEvent, expectedEvent)
    }
}

// MARK: - Tracking
extension LyticsTests {
    func testOptIn() async {
        let optInExpectation = expectation(description: "Opted in")
        let eventPipeline = EventPipelineMock(onOptIn: { optInExpectation.fulfill() })

        let sut = Lytics(
            logger: .mock,
            dependencies: .test(eventPipeline: eventPipeline)
        )

        sut.optIn()
        await waitForExpectations(timeout: expectationTimeout)
    }

    func testOptInBeforeStarting() {
        let failureExpectation = expectation(description: "Not started failure")
        let sut = Lytics(assertionFailure: { _, _, _ in failureExpectation.fulfill() }, logger: .mock)

        sut.optIn()
        waitForExpectations(timeout: expectationTimeout)
    }

    func testOptOut() async {
        let optOutExpectation = expectation(description: "Opted out")
        let eventPipeline = EventPipelineMock(onOptOut: { optOutExpectation.fulfill() })

        let sut = Lytics(
            logger: .mock,
            dependencies: .test(eventPipeline: eventPipeline)
        )

        sut.optOut()
        await waitForExpectations(timeout: expectationTimeout)
    }

    func testOptOutBeforeStarting() {
        let failureExpectation = expectation(description: "Not started failure")
        let sut = Lytics(assertionFailure: { _, _, _ in failureExpectation.fulfill() }, logger: .mock)

        sut.optOut()
        waitForExpectations(timeout: expectationTimeout)
    }

    func testRequestTrackingAuthorization() async {
        let expectedIDFA = "1234"
        let expectedAuthorized = true

        let idfaExpectation = expectation(description: "IDFA fetched")
        let requestExpectation = expectation(description: "Authorization requested")
        let appTrackingTransparency = AppTrackingTransparency.test(
            idfa: {
                defer { idfaExpectation.fulfill() }
                return expectedIDFA
            },
            requestAuthorization: {
                defer { requestExpectation.fulfill() }
                return expectedAuthorized
            }
        )

        let updateExpectation = expectation(description: "User updated")
        let userManager = UserManagerMock<[String: AnyCodable], Never>(
            onUpdateIdentifiers: { identifiers in
                self.actualIdentifierDictionary = identifiers
                updateExpectation.fulfill()
                return User1.anyIdentifiers
            }
        )

        let sut = Lytics(
            logger: .mock,
            dependencies: .test(
                appTrackingTransparency: appTrackingTransparency,
                userManager: userManager
            )
        )

        let actualAuthorized = await sut.requestTrackingAuthorization()

        await waitForExpectations(timeout: expectationTimeout)
        XCTAssertEqual(actualAuthorized, expectedAuthorized)
        XCTAssertEqual(actualIdentifierDictionary, ["idfa": AnyCodable(expectedIDFA)])
    }

    func testRequestTrackingAuthorizationBeforeStarting() async {
        let failureExpectation = expectation(description: "Not started failure")
        let sut = Lytics(assertionFailure: { _, _, _ in failureExpectation.fulfill() }, logger: .mock)

        _ = await sut.requestTrackingAuthorization()
        await waitForExpectations(timeout: expectationTimeout)
    }

    func testDisableTracking() async {
        let disableExpectation = expectation(description: "Tracking disabled")
        let appTrackingTransparency = AppTrackingTransparency.test(
            disableIDFA: { disableExpectation.fulfill() }
        )

        let sut = Lytics(
            logger: .mock,
            dependencies: .test(appTrackingTransparency: appTrackingTransparency)
        )

        sut.disableTracking()
        await waitForExpectations(timeout: expectationTimeout)
    }

    func testDisableTrackingBeforeStarting() {
        let failureExpectation = expectation(description: "Not started failure")
        let sut = Lytics(assertionFailure: { _, _, _ in failureExpectation.fulfill() }, logger: .mock)

        sut.disableTracking()
        waitForExpectations(timeout: expectationTimeout)
    }
}

// MARK: - Utility
extension LyticsTests {
    func testDispatch() async {
        let dispatchExpectation = expectation(description: "Events dispatched")
        let eventPipeline = EventPipelineMock(
            onDispatch: { dispatchExpectation.fulfill() }
        )

        let sut = Lytics(
            logger: .mock,
            dependencies: .test(
                eventPipeline: eventPipeline
            )
        )

        sut.dispatch()
        await waitForExpectations(timeout: expectationTimeout)
    }

    func testDispatchBeforeStarting() {
        let failureExpectation = expectation(description: "Not started failure")
        let sut = Lytics(assertionFailure: { _, _, _ in failureExpectation.fulfill() }, logger: .mock)

        sut.dispatch()
        waitForExpectations(timeout: expectationTimeout)
    }

    func testRemoveIdentifier() async {
        let expectedDictPath = DictPath("identifier")

        var actualDictPath: DictPath!
        let removalExpectation = expectation(description: "Identifier removed")
        let userManager = UserManagerMock<Never, Never>(
            onRemoveIdentifier: { path in
                actualDictPath = path
                removalExpectation.fulfill()
            }
        )

        let sut = Lytics(
            logger: .mock,
            dependencies: .test(
                userManager: userManager
            )
        )

        sut.removeIdentifier(expectedDictPath)

        await waitForExpectations(timeout: expectationTimeout)
        XCTAssertEqual(actualDictPath, expectedDictPath)
    }

    func testRemoveAttribute() async {
        let expectedDictPath = DictPath("attribute")

        var actualDictPath: DictPath!
        let removalExpectation = expectation(description: "Attribute removed")
        let userManager = UserManagerMock<Never, Never>(
            onRemoveAttribute: { path in
                actualDictPath = path
                removalExpectation.fulfill()
            }
        )

        let sut = Lytics(
            logger: .mock,
            dependencies: .test(
                userManager: userManager
            )
        )

        sut.removeAttribute(expectedDictPath)

        await waitForExpectations(timeout: expectationTimeout)
        XCTAssertEqual(actualDictPath, expectedDictPath)
    }

    func testReset() async {
        let disableTrackingExpectation = expectation(description: "Tracking disabled")
        let appTrackingTransparency = AppTrackingTransparency.test(
            disableIDFA: { disableTrackingExpectation.fulfill() }
        )

        let optOutExpectation = expectation(description: "Opted out")
        let eventPipeline = EventPipelineMock(
            onOptOut: { optOutExpectation.fulfill() }
        )

        let clearUserExpectation = expectation(description: "User cleared")
        let userManager = UserManagerMock<Never, Never>(
            onClear: { clearUserExpectation.fulfill() }
        )

        let sut = Lytics(
            logger: .mock,
            dependencies: .test(
                appTrackingTransparency: appTrackingTransparency,
                eventPipeline: eventPipeline,
                userManager: userManager
            )
        )

        sut.reset()
        await waitForExpectations(timeout: expectationTimeout)
    }

    func testResetBeforeStarting() {
        let failureExpectation = expectation(description: "Not started failure")
        let sut = Lytics(assertionFailure: { _, _, _ in failureExpectation.fulfill() }, logger: .mock)

        sut.reset()
        waitForExpectations(timeout: expectationTimeout)
    }
}
