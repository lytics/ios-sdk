//
//  EventPipelineTests.swift
//
//  Created by Mathew Gacy on 11/9/22.
//

@testable import Lytics
import XCTest

final class EventPipelineTests: XCTestCase {

    func testStreamNameIfConfigurationEmpty() async throws {
        var enqueuedEvent: StreamEvent!
        let eventQueue = EventQueueMock(onEnqueue: { event in
            enqueuedEvent = event
        })

        let sut = EventPipeline(
            configuration: .init(
                defaultStream: "",
                requireConsent: false
            ),
            logger: .mock,
            sessionDidStart: { _ in false },
            eventQueue: eventQueue,
            uploader: UploaderMock<DataUploadResponse>(),
            userSettings: .optedInMock
        )

        await sut.event(stream: nil, timestamp: 0, name: nil, event: Mock.event)
        XCTAssertEqual(enqueuedEvent.stream, Constants.defaultStream)

        await sut.event(stream: "", timestamp: 0, name: nil, event: Mock.event)
        XCTAssertEqual(enqueuedEvent.stream, Constants.defaultStream)

        let expectedName = "expected"
        await sut.event(stream: expectedName, timestamp: 0, name: nil, event: Mock.event)
        XCTAssertEqual(enqueuedEvent.stream, expectedName)
    }

    func testWillSendIfNotRequireConsent() async throws {
        var enqueuedEvent: StreamEvent!
        let eventQueue = EventQueueMock(onEnqueue: { event in
            enqueuedEvent = event
        })

        let sut = EventPipeline(
            configuration: .init(
                defaultStream: "",
                requireConsent: false
            ),
            logger: .mock,
            sessionDidStart: { _ in false },
            eventQueue: eventQueue,
            uploader: UploaderMock<DataUploadResponse>(),
            userSettings: .optedOutMock
        )

        await sut.event(stream: nil, timestamp: 0, name: nil, event: Mock.event)
        XCTAssertEqual(enqueuedEvent.stream, Constants.defaultStream)
    }

    func testWillSendIfRequireConsentAndOptedIn() async throws {
        var enqueuedEvent: StreamEvent!
        let eventQueue = EventQueueMock(onEnqueue: { event in
            enqueuedEvent = event
        })

        let sut = EventPipeline(
            configuration: .init(
                defaultStream: "",
                requireConsent: true
            ),
            logger: .mock,
            sessionDidStart: { _ in false },
            eventQueue: eventQueue,
            uploader: UploaderMock<DataUploadResponse>(),
            userSettings: .optedInMock
        )

        await sut.event(stream: nil, timestamp: 0, name: nil, event: Mock.event)
        XCTAssertEqual(enqueuedEvent.stream, Constants.defaultStream)
    }

    func testWillNotSendIfRequireConsentAndOptedOut() async throws {
        var enqueuedEvent: StreamEvent?
        let eventQueue = EventQueueMock(onEnqueue: { event in
            enqueuedEvent = event
        })

        let sut = EventPipeline(
            configuration: .init(
                defaultStream: "",
                requireConsent: true
            ),
            logger: .mock,
            sessionDidStart: { _ in false },
            eventQueue: eventQueue,
            uploader: UploaderMock<DataUploadResponse>(),
            userSettings: .optedOutMock
        )

        await sut.event(stream: nil, timestamp: 0, name: nil, event: Mock.event)
        XCTAssertNil(enqueuedEvent)
    }

    func testNoSpacesInStreamName() async throws {
        var enqueuedEvent: StreamEvent!
        let eventQueue = EventQueueMock(onEnqueue: { event in
            enqueuedEvent = event
        })

        let sut = EventPipeline(
            configuration: .init(
                defaultStream: Constants.defaultStream,
                requireConsent: false
            ),
            logger: .mock,
            sessionDidStart: { _ in false },
            eventQueue: eventQueue,
            uploader: UploaderMock<DataUploadResponse>(),
            userSettings: .optedOutMock
        )

        await sut.event(stream: "has empty spaces", timestamp: 0, name: nil, event: Mock.event)
        XCTAssertEqual(enqueuedEvent.stream, "has_empty_spaces")
    }

    func testOptIn() {
        let optInExpectation = expectation(description: "Opted in")
        var optInValue: Bool!
        let settings = UserSettings(
            getOptIn: { true },
            setOptIn: { optedIn in
                optInValue = optedIn
                optInExpectation.fulfill()
            }
        )

        let sut = EventPipeline(
            configuration: .init(
                defaultStream: "",
                requireConsent: false
            ),
            logger: .mock,
            sessionDidStart: { _ in false },
            eventQueue: EventQueueMock(),
            uploader: UploaderMock<DataUploadResponse>(),
            userSettings: settings
        )

        sut.optIn()
        waitForExpectations(timeout: 0.1)
        XCTAssertEqual(optInValue, true)
    }

    func testOptOut() {
        let optOutExpectation = expectation(description: "Opted out")
        var optOutValue: Bool!
        let settings = UserSettings(
            getOptIn: { true },
            setOptIn: { optedIn in
                optOutValue = optedIn
                optOutExpectation.fulfill()
            }
        )

        let sut = EventPipeline(
            configuration: .init(
                defaultStream: "",
                requireConsent: false
            ),
            logger: .mock,
            sessionDidStart: { _ in false },
            eventQueue: EventQueueMock(),
            uploader: UploaderMock<DataUploadResponse>(),
            userSettings: settings
        )

        sut.optOut()
        waitForExpectations(timeout: 0.1)
        XCTAssertEqual(optOutValue, false)
    }

    func testIsOptedIn() {
        let getOptInExpectation = expectation(description: "Got optIn")
        let isOptedIn = true
        let settings = UserSettings(
            getOptIn: {
                getOptInExpectation.fulfill()
                return isOptedIn
            },
            setOptIn: { _ in }
        )

        let sut = EventPipeline(
            configuration: .init(
                defaultStream: "",
                requireConsent: false
            ),
            logger: .mock,
            sessionDidStart: { _ in false },
            eventQueue: EventQueueMock(),
            uploader: UploaderMock<DataUploadResponse>(),
            userSettings: settings
        )

        let actualValue = sut.isOptedIn
        waitForExpectations(timeout: 0.1)
        XCTAssertEqual(actualValue, isOptedIn)
    }

    func testDispatch() async {
        let flushExpectation = expectation(description: "EventQueue was flushed")
        let eventQueue = EventQueueMock(onFlush: {
            flushExpectation.fulfill()
        })

        let sut = EventPipeline(
            configuration: .init(
                defaultStream: Constants.defaultStream,
                requireConsent: false
            ),
            logger: .mock,
            sessionDidStart: { _ in false },
            eventQueue: eventQueue,
            uploader: UploaderMock<DataUploadResponse>(),
            userSettings: .optedOutMock
        )

        await sut.dispatch()
        await waitForExpectations(timeout: 0.3)
    }
}
