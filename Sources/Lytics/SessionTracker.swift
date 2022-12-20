//
//  SessionTracker.swift
//
//  Created by Mathew Gacy on 10/22/22.
//

import Foundation

enum SessionTracker {

    /// Stores the given timestamp and returns the difference between it and the last stored timestamp.
    /// - Parameter timestamp: The given timestamp
    /// - Returns: The difference between the given timestamp and the last stored one.
    @discardableResult
    static func markInteraction(_ timestamp: Millisecond) -> Millisecond {
        let lastTimestamp = UserDefaults.standard.int64(for: .lastEventTimestamp)
        UserDefaults.standard.set(timestamp, for: .lastEventTimestamp)
        return timestamp - lastTimestamp
    }
}
