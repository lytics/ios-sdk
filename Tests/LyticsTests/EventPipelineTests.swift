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
                requireConsent: false),
            logger: .mock,
            sessionDidStart: { _ in false },
            eventQueue: eventQueue,
            uploader: UploaderMock<DataUploadResponse>(),
            userSettings: .optedInMock)

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
                requireConsent: false),
            logger: .mock,
            sessionDidStart: { _ in false },
            eventQueue: eventQueue,
            uploader: UploaderMock<DataUploadResponse>(),
            userSettings: .optedOutMock)

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
                requireConsent: true),
            logger: .mock,
            sessionDidStart: { _ in false },
            eventQueue: eventQueue,
            uploader: UploaderMock<DataUploadResponse>(),
            userSettings: .optedInMock)

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
                requireConsent: true),
            logger: .mock,
            sessionDidStart: { _ in false },
            eventQueue: eventQueue,
            uploader: UploaderMock<DataUploadResponse>(),
            userSettings: .optedOutMock)

        await sut.event(stream: nil, timestamp: 0, name: nil, event: Mock.event)
        XCTAssertNil(enqueuedEvent)
    }
}
