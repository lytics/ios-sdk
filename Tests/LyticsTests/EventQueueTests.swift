//
//  EventQueueTests.swift
//
//  Created by Mathew Gacy on 10/18/22.
//

@testable import Lytics
import XCTest

final class EventQueueTests: XCTestCase {

    func testFlushAfterMaxQueueSize() async throws {
        let buildExpectation = expectation(description: "Requests built")

        let requestBuilder = DataUploadRequestBuilder(
            requests: { _ in
                buildExpectation.fulfill()
                return []
            })

        let sut = EventQueue(
            logger: .mock,
            maxQueueSize: 3,
            uploadInterval: 10,
            requestBuilder: requestBuilder,
            upload: { _ in })

        buildExpectation.isInverted = true

        await sut.enqueue(Mock.payload(event: Mock.consentEvent))
        await sut.enqueue(Mock.payload(event: Mock.event))
        buildExpectation.isInverted = false
        await sut.enqueue(Mock.payload(event: Mock.identityEvent))

        await waitForExpectations(timeout: 1.0)
    }

    func testFlushAfterUploadInterval() async throws {
        let buildExpectation = expectation(description: "Requests built")

        let requestBuilder = DataUploadRequestBuilder(
            requests: { _ in
                buildExpectation.fulfill()
                return []
            })

        let sut = EventQueue(
            logger: .mock,
            maxQueueSize: 10,
            uploadInterval: 1,
            requestBuilder: requestBuilder,
            upload: { _ in })

        await sut.enqueue(Mock.payload(event: Mock.consentEvent))
        await sut.enqueue(Mock.payload(event: Mock.event))
        await sut.enqueue(Mock.payload(event: Mock.identityEvent))
        await waitForExpectations(timeout: 2.0)
    }

    func testManualFlush() async throws {
        let buildExpectation = expectation(description: "Requests built")

        let requestBuilder = DataUploadRequestBuilder(
            requests: { _ in
                buildExpectation.fulfill()
                return []
            })

        let sut = EventQueue(
            logger: .mock,
            maxQueueSize: 10,
            uploadInterval: 10,
            requestBuilder: requestBuilder,
            upload: { _ in })

        await sut.enqueue(Mock.payload(event: Mock.consentEvent))
        await sut.flush()

        await waitForExpectations(timeout: 1.0)
        let isEmpty = await sut.isEmpty
        XCTAssert(isEmpty)
        let eventCount = await sut.eventCount
        XCTAssertEqual(eventCount, 0)
    }

    func testTimerTaskAfterEnqueue() async throws {
        let sut = EventQueue(
            logger: .mock,
            maxQueueSize: 10,
            uploadInterval: 1,
            requestBuilder: .mock,
            upload: { _ in })

        let isEmpty = await sut.isEmpty
        XCTAssert(isEmpty)

        let hasTimerTaskBefore = await sut.hasTimerTask
        XCTAssert(!hasTimerTaskBefore)

        await sut.enqueue(Mock.payload(event: Mock.event))

        let hasTimerTaskAfter = await sut.hasTimerTask
        XCTAssert(hasTimerTaskAfter)
    }

    func testLogErrors() async throws {
        let logExpectation = expectation(description: "Error logged")
        let logger = LyticsLogger(log: { logType, _, _, _, _ in
            XCTAssertEqual(logType, .error)
            logExpectation.fulfill()
        })

        let requestBuilder = DataUploadRequestBuilder(
            requests: { _ in
                throw NSError(domain: "", code: 1)
            })

        let sut = EventQueue(
            logger: logger,
            maxQueueSize: 10,
            uploadInterval: 10,
            requestBuilder: requestBuilder,
            upload: { _ in })

        await sut.enqueue(Mock.payload(event: Mock.event))
        await sut.flush()

        await waitForExpectations(timeout: 0.5)
    }

    func testEventsUploaded() async throws {
        let requests = [Mock.request]

        let requestBuilder = DataUploadRequestBuilder(
            requests: { _ in
                return requests
            })

        var uploadedRequests: [Request<DataUploadResponse>]!
        let uploadExpectation = expectation(description: "Requests sent to uploader")

        let upload = { requests in
            uploadedRequests = requests
            uploadExpectation.fulfill()
        }

        let sut = EventQueue(
            logger: .mock,
            maxQueueSize: 10,
            uploadInterval: 10,
            requestBuilder: requestBuilder,
            upload: upload)

        await sut.enqueue(Mock.payload(event: Mock.event))
        await sut.flush()

        await waitForExpectations(timeout: 0.5)

        XCTAssertEqual(uploadedRequests, requests)
    }

    func testStreamBatching() async throws {
        let buildExpectation = expectation(description: "Requests built")

        var events: [String: [any StreamEvent]]!
        let requestBuilder = DataUploadRequestBuilder(
            requests: { passedEvents in
                events = passedEvents
                buildExpectation.fulfill()
                return []
            })

        let sut = EventQueue(
            logger: .mock,
            maxQueueSize: 3,
            uploadInterval: 10,
            requestBuilder: requestBuilder,
            upload: { _ in })


        await sut.enqueue(Mock.payload(stream: Stream.one, name: Name.one, event: Mock.event))
        await sut.enqueue(Mock.payload(stream: Stream.two, name: Name.two, event: Mock.event))
        await sut.enqueue(Mock.payload(stream: Stream.one, name: Name.three, event: Mock.event))
        await sut.flush()

        await waitForExpectations(timeout: 0.5)

        let stream1Events = events[Stream.one]!
        XCTAssertEqual(stream1Events.count, 2)
        XCTAssertEqual(stream1Events.first!.name, Name.one)
        XCTAssertEqual(stream1Events.last!.name, Name.three)

        let stream2Events = events[Stream.two]!
        XCTAssertEqual(stream2Events.count, 1)
        XCTAssertEqual(stream2Events.first!.name, Name.two)
    }
}
