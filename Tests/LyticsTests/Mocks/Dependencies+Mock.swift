//
//  Dependencies+Mock.swift
//
//  Created by Mathew Gacy on 10/18/22.
//

import class AppTrackingTransparency.ATTrackingManager
import Foundation
@testable import Lytics
import os.log
import XCTest

extension AppTrackingTransparency {
    static func test(
        authorizationStatus: @escaping () -> ATTrackingManager.AuthorizationStatus = { XCTFail("AppTrackingTransparency.authorizationStatus"); return .denied },
        disableIDFA: @escaping () -> Void = { XCTFail("AppTrackingTransparency.disableIDFA") },
        enableIDFA: @escaping () -> Void = { XCTFail("AppTrackingTransparency.enableIDFA") },
        idfa: @escaping @Sendable () -> String? = { XCTFail("AppTrackingTransparency.idfa"); return nil },
        requestAuthorization: @escaping () async -> Bool = { XCTFail("AppTrackingTransparency.requestAuthorization"); return false }
    ) -> Self {
        .init(
            authorizationStatus: authorizationStatus,
            disableIDFA: disableIDFA,
            enableIDFA: enableIDFA,
            idfa: idfa,
            requestAuthorization: requestAuthorization
        )
    }
}

extension AppVersionTracker {
    static func mock(_ event: AppVersionEvent? = nil) -> Self {
        .init {
            event
        }
    }

    static func test(
        checkVersion: @escaping @Sendable () -> AppVersionEvent? = { XCTFail("\(Self.self).checkVersion"); return nil }
    ) -> Self {
        .init(
            checkVersion: checkVersion
        )
    }
}

extension DataUploadRequestBuilder {
    static let mock = Self(
        requests: { _ in [] }
    )

    static func test(
        requests: @escaping ([String: [any StreamEvent]]) throws -> [Request<DataUploadResponse>] = { _ in XCTFail("\(Self.self).requests"); return [] }
    ) -> Self {
        .init(
            requests: requests
        )
    }
}

extension DependencyContainer {
    static func test(
        appTrackingTransparency: AppTrackingTransparency = .test(),
        configuration: LyticsConfiguration = .init(),
        eventPipeline: EventPipelineProtocol = EventPipelineMock(),
        timestampProvider: @escaping @Sendable () -> Millisecond = Millisecond.test(),
        userManager: UserManaging = UserManagerMock<TestIdentifiers, TestAttributes>(),
        apiToken: String = Mock.apiToken,
        appEventTracker: AppEventTracking = AppEventTrackerMock(),
        loader: Loader = .test()
    ) -> Self {
        .init(
            apiToken: apiToken,
            appEventTracker: appEventTracker,
            appTrackingTransparency: appTrackingTransparency,
            configuration: configuration,
            eventPipeline: eventPipeline,
            loader: loader,
            timestampProvider: timestampProvider,
            userManager: userManager
        )
    }
}

extension Loader {
    static let mock = Self(
        entity: { _, _ in Mock.entity }
    )

    static func test(
        entity: @escaping (Table, EntityIdentifier) async throws -> Entity = { _, _ in XCTFail("\(Self.self).entity"); return Mock.entity }
    ) -> Self {
        .init(
            entity: entity
        )
    }
}

extension LyticsLogger {
    static let mock = Self(
        log: { _, _, _, _, _ in }
    )

    static func test(
        log: @escaping (OSLogType, @escaping () -> String, StaticString, StaticString, UInt) -> Void = { _, _, _, _, _ in XCTFail("\(Self.self).log") }
    ) -> Self {
        .init(log: log)
    }
}

extension Millisecond {
    static let mock: @Sendable () -> Self = {
        Mock.millisecond
    }

    static func test(
        _ provider: @escaping @Sendable () -> Millisecond = { XCTFail("timestampProvider"); return 0 }
    ) -> @Sendable () -> Self {
        provider
    }
}

extension RequestBuilder {
    static let mock = Self(
        apiToken: Mock.apiToken,
        collectionEndpoint: Constants.collectionEndpoint,
        entityEndpoint: Constants.entityEndpoint
    )
}

extension RequestFailureHandler {
    static let failing = Self(
        strategy: { error, _ in
            XCTFail("Unexpected request failure: \(error.localizedDescription)")
            return .discard("")
        }
    )

    static let discarding = Self(
        strategy: { _, _ in .discard("") }
    )

    static func test(
        strategy: @escaping (Error, Int) -> Strategy = { _, _ in XCTFail("RequestFailureHandler.strategy"); return .discard("") }
    ) -> Self {
        .init(
            strategy: strategy
        )
    }
}

extension Storage {
    static let mock = Self(
        write: { _ in },
        read: { nil },
        clear: {}
    )

    static func test(
        write: @escaping (Data) throws -> Void = { _ in XCTFail("Storage.write") },
        read: @escaping () throws -> Data? = { XCTFail("Storage.read"); return nil },
        clear: @escaping () throws -> Void = { XCTFail("Storage.clear") }
    ) -> Self {
        .init(
            write: write,
            read: read,
            clear: clear
        )
    }
}

extension UserSettings {
    static let optedInMock = Self(
        getOptIn: { true },
        setOptIn: { _ in }
    )

    static let optedOutMock = Self(
        getOptIn: { false },
        setOptIn: { _ in }
    )

    static func test(
        getOptIn: @escaping () -> Bool = { XCTFail("UserSettings.setOptIn"); return false },
        setOptIn: @escaping (Bool) -> Void = { _ in XCTFail("UserSettings.setOptIn") }
    ) -> Self {
        .init(
            getOptIn: getOptIn,
            setOptIn: setOptIn
        )
    }
}
