//
//  Dependencies+Mock.swift
//
//  Created by Mathew Gacy on 10/18/22.
//

import Foundation
@testable import Lytics
import XCTest

extension AppVersionTracker {
    static let failing = Self(
        checkVersion: { XCTFail("\(Self.self).checkVersion"); return nil }
    )

    static func mock(_ event: AppVersionEvent? = nil) -> Self {
        .init {
            event
        }
    }
}

extension DataUploadRequestBuilder {
    static let failing = Self(
        requests: { _ in XCTFail("\(Self.self).requests"); return [] }
    )

    static let mock = Self(
        requests: { _ in [] }
    )
}

extension Loader {
    static let failing = Self(
        entity: { _, _ in XCTFail("\(Self.self).entity"); return Mock.entity }
    )

    static let mock = Self(
        entity: { _, _ in Mock.entity }
    )
}

extension LyticsLogger {
    static let failing = Self(
        log: { _, _, _, _, _ in XCTFail("\(Self.self).log") }
    )

    static let mock = Self(
        log: { _, _, _, _, _ in }
    )
}

extension Millisecond {
    static let failing: () -> Self = {
        XCTFail("timestampProvider"); return 0
    }

    static let mock: () -> Self = {
        Mock.millisecond
    }
}

extension RequestBuilder {
    static let mock = Self(
        baseURL: Constants.defaultBaseURL,
        apiToken: Mock.apiToken
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
}

extension Storage {
    static let failing = Self(
        write: { _ in XCTFail("Storage.write") },
        read: { XCTFail("Storage.read"); return nil },
        clear: { XCTFail("Storage.clear") }
    )

    static let mock = Self(
        write: { _ in },
        read: { nil },
        clear: {}
    )
}

extension UserSettings {
    static let failing = Self(
        getOptIn: { XCTFail("UserSettings.setOptIn"); return false },
        setOptIn: { _ in XCTFail("UserSettings.setOptIn") }
    )

    static let optedInMock = Self(
        getOptIn: { true },
        setOptIn: { _ in }
    )

    static let optedOutMock = Self(
        getOptIn: { false },
        setOptIn: { _ in }
    )
}
