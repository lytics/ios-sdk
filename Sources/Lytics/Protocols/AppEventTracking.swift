//
//  AppEventTracking.swift
//
//  Created by Mathew Gacy on 10/23/22.
//

import Foundation

/// A type that tracks application events.
protocol AppEventTracking {

    /// Starts tracking application events.
    /// - Parameter lifecycleEvents: An asynchronous sequence of app lifecycle events.
    func startTracking<S: AsyncSequence>(lifecycleEvents: S) where S.Element == AppLifecycleEvent

    /// Stops tracking application events.
    func stopTracking()
}
