//
//  Dependencies+Mock.swift
//
//  Created by Mathew Gacy on 10/18/22.
//

import Foundation
@testable import Lytics
import XCTest

extension AppVersionTracker {
    static func mock(_ event: AppVersionEvent? = nil) -> Self {
        .init {
            event
        }
    }
}

extension DataUploadRequestBuilder {
    static var mock: Self {
        .init(requests: { _ in [] })
    }
}

extension Loader {
    static var failing: Self {
        .init(
            entity: { _, _ in XCTFail("\(Self.self).entity"); return Mock.entity }
        )
    }

    static var mock: Self {
        .init(
            entity: { _, _ in Mock.entity }
        )
    }
}

extension LyticsLogger {
    static var mock: Self {
        .init(log: { _, _, _, _, _ in })
    }
}

extension RequestBuilder {
    static var mock: Self {
        .init(
            baseURL: Constants.defaultBaseURL,
            apiToken: Mock.apiToken
        )
    }
}

extension RequestFailureHandler {
    static var failing: Self {
        .init(
            strategy: { error, _ in
                XCTFail("Unexpected request failure: \(error.localizedDescription)")
                return .discard("")
            }
        )
    }

    static var mock: Self {
        .init(
            strategy: { _, _ in .discard("") }
        )
    }
}

extension Storage {
    static var mock: Self {
        .init(
            write: { _ in XCTFail("Storage.write") },
            read: { XCTFail("Storage.read"); return nil },
            clear: { XCTFail("Storage.clear") }
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
}
