//
//  AppEventTrackerMock.swift
//
//  Created by Mathew Gacy on 1/24/23.
//

import Foundation
@testable import Lytics
import XCTest

struct AppEventTrackerMock: AppEventTracking {
    var onStart: () -> Void = { XCTFail("\(Self.self).onStart") }
    var onStop: () -> Void = { XCTFail("\(Self.self).onStop") }

    func startTracking<S: AsyncSequence>(lifecycleEvents: S, versionTracker: AppVersionTracker) where S.Element == AppLifecycleEvent {
        onStart()
    }

    func stopTracking() {
        onStop()
    }
}
