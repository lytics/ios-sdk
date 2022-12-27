//
//  AppEventTrackerTests.swift
//
//  Created by Mathew Gacy on 11/10/22.
//

@testable import Lytics
import XCTest

final class AppEventTrackerTests: XCTestCase {

    func testOnEventCalled() async throws {
        var handledEvent: AppLifecycleEvent?
        var handlerExpectation: XCTestExpectation!
        let eventHandler: (AppLifecycleEvent) -> Void = { event in
            handledEvent = event
            handlerExpectation.fulfill()
        }

        let sut = AppEventTracker(
            configuration: .init(stream: "Stream", trackApplicationLifecycleEvents: true),
            logger: .mock,
            eventProvider: AppEventProvider(identifiers: { [:] }),
            eventPipeline: EventPipelineMock(),
            onEvent: eventHandler
        )

        let center = NotificationCenter()
        sut.startTracking(
            lifecycleEvents: center.lifecycleEvents(),
            versionTracker: .mock()
        )

        // didBecomeActive
        handlerExpectation = expectation(description: "didBecomeActive handled")
        await center.post(name: UIApplication.didBecomeActiveNotification, object: nil)
        await waitForExpectations(timeout: 1.0)
        XCTAssertEqual(handledEvent, .didBecomeActive)

        // didEnterBackground
        handlerExpectation = expectation(description: "didEnterBackground handled")
        await center.post(name: UIApplication.didEnterBackgroundNotification, object: nil)
        await waitForExpectations(timeout: 1.0)
        XCTAssertEqual(handledEvent, .didEnterBackground)

        // willTerminate
        handlerExpectation = expectation(description: "willTerminate handled")
        await center.post(name: UIApplication.willTerminateNotification, object: nil)
        await waitForExpectations(timeout: 1.0)
        XCTAssertEqual(handledEvent, .willTerminate)
    }

    func testTrackerDeinit() async throws {
        var handlerExpectation: XCTestExpectation!
        let eventHandler: (AppLifecycleEvent) -> Void = { _ in
            handlerExpectation.fulfill()
        }

        var sut: AppEventTracker? = AppEventTracker(
            configuration: .init(stream: "Stream", trackApplicationLifecycleEvents: true),
            logger: .mock,
            eventProvider: AppEventProvider(identifiers: { [:] }),
            eventPipeline: EventPipelineMock(),
            onEvent: eventHandler
        )

        let center = NotificationCenter()
        sut!.startTracking(
            lifecycleEvents: center.lifecycleEvents(),
            versionTracker: .mock()
        )

        handlerExpectation = expectation(description: "Event handled")
        await center.post(name: UIApplication.didBecomeActiveNotification, object: nil)
        await waitForExpectations(timeout: 1.0)

        sut = nil

        // Send another event and give it time to call eventHandler
        handlerExpectation = expectation(description: "Event not handled")
        handlerExpectation.isInverted = true
        await center.post(name: UIApplication.didBecomeActiveNotification, object: nil)
        await waitForExpectations(timeout: 1.0)
    }

    func testAppLifecycleEventsSent() async throws {
        let expectedStream = "Stream"

        var eventExpectation: XCTestExpectation!
        var streamName: String!
        var eventName: String!
        let eventPipeline = EventPipelineMock(
            onEvent: { stream, _, name, _ in
                streamName = stream
                eventName = name
                eventExpectation.fulfill()
            })

        let sut = AppEventTracker(
            configuration: .init(stream: expectedStream, trackApplicationLifecycleEvents: true),
            logger: .mock,
            eventProvider: AppEventProvider(identifiers: { [:] }),
            eventPipeline: eventPipeline,
            onEvent: { _ in }
        )

        let center = NotificationCenter()
        sut.startTracking(
            lifecycleEvents: center.lifecycleEvents(),
            versionTracker: .mock()
        )

        // didBecomeActive
        eventExpectation = expectation(description: "didBecomeActive sent")
        await center.post(name: UIApplication.didBecomeActiveNotification, object: nil)
        await waitForExpectations(timeout: 1.0)
        XCTAssertEqual(eventName, EventNames.appOpen)
        XCTAssertEqual(streamName, expectedStream)

        // didEnterBackground
        eventExpectation = expectation(description: "didEnterBackground sent")
        await center.post(name: UIApplication.didEnterBackgroundNotification, object: nil)
        await waitForExpectations(timeout: 1.0)
        XCTAssertEqual(eventName, EventNames.appBackground)
        XCTAssertEqual(streamName, expectedStream)
    }

    func testAppLifecycleEventsNotSentIfDisabled() async throws {
        let eventExpectation = expectation(description: "")
        eventExpectation.isInverted = true
        let eventPipeline = EventPipelineMock(
            onEvent: { _, _, _, _ in
                eventExpectation.fulfill()
            })

        let sut = AppEventTracker(
            configuration: .init(stream: "", trackApplicationLifecycleEvents: false),
            logger: .mock,
            eventProvider: AppEventProvider(identifiers: { [:] }),
            eventPipeline: eventPipeline,
            onEvent: { _ in }
        )

        let center = NotificationCenter()
        sut.startTracking(
            lifecycleEvents: center.lifecycleEvents(),
            versionTracker: .mock()
        )

        await center.post(name: UIApplication.didBecomeActiveNotification, object: nil)
        await center.post(name: UIApplication.didEnterBackgroundNotification, object: nil)
        await center.post(name: UIApplication.willTerminateNotification, object: nil)

        await waitForExpectations(timeout: 1.0)
    }

    func testAppVersionEventsSent() async throws {
        var eventExpectation: XCTestExpectation!
        var eventName: String!
        let eventPipeline = EventPipelineMock(
            onEvent: { _, _, name, _ in
                eventName = name
                eventExpectation.fulfill()
            })

        let sut = AppEventTracker(
            configuration: .init(stream: "", trackApplicationLifecycleEvents: false),
            logger: .mock,
            eventProvider: AppEventProvider(identifiers: { [:] }),
            eventPipeline: eventPipeline,
            onEvent: { _ in }
        )

        let center = NotificationCenter()

        // Install
        eventExpectation = expectation(description: "Install event sent")
        sut.startTracking(
            lifecycleEvents: center.lifecycleEvents(),
            versionTracker: .mock(.install("1.0"))
        )
        await waitForExpectations(timeout: 1.0)
        XCTAssertEqual(eventName, EventNames.appInstall)
        sut.stopTracking()

        // Update
        eventExpectation = expectation(description: "Update event sent")
        sut.startTracking(
            lifecycleEvents: center.lifecycleEvents(),
            versionTracker: .mock(.update("1.1"))
        )
        await waitForExpectations(timeout: 1.0)
        XCTAssertEqual(eventName, EventNames.appUpdate)
        sut.stopTracking()
    }

    func testStopTracking() async throws {
        var eventExpectation: XCTestExpectation!
        let eventPipeline = EventPipelineMock(
            onEvent: { _, _, _, _ in
                eventExpectation.fulfill()
            })

        var handlerExpectation: XCTestExpectation!
        let eventHandler: (AppLifecycleEvent) -> Void = { _ in
            handlerExpectation.fulfill()
        }

        let sut = AppEventTracker(
            configuration: .init(stream: "", trackApplicationLifecycleEvents: true),
            logger: .mock,
            eventProvider: AppEventProvider(identifiers: { [:] }),
            eventPipeline: eventPipeline,
            onEvent: eventHandler
        )

        let center = NotificationCenter()
        sut.startTracking(
            lifecycleEvents: center.lifecycleEvents(),
            versionTracker: .mock()
        )

        eventExpectation = expectation(description: "didBecomeActive sent")
        handlerExpectation = expectation(description: "Event handled")
        await center.post(name: UIApplication.didBecomeActiveNotification, object: nil)
        await waitForExpectations(timeout: 1.0)

        eventExpectation = expectation(description: "Event not sent")
        eventExpectation.isInverted = true
        handlerExpectation = expectation(description: "Event not handled")
        handlerExpectation.isInverted = true

        sut.stopTracking()
        await center.post(name: UIApplication.didBecomeActiveNotification, object: nil)
        await waitForExpectations(timeout: 1.0)
    }
}
