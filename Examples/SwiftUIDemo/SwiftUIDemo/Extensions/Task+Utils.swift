//
//  Task+Utils.swift
//  SwiftUIDemo
//
//  Created by Mathew Gacy on 10/25/22.
//  Copyright © 2022 Lytics. All rights reserved.
//

import Foundation

extension Task where Failure == Error {
    static func delayed(
        byTimeInterval delayInterval: TimeInterval,
        priority: TaskPriority? = nil,
        operation: @escaping @Sendable () async throws -> Success
    ) -> Task {
        Task(priority: priority) {
            let delay = UInt64(delayInterval * 1_000_000_000)
            try await Task<Never, Never>.sleep(nanoseconds: delay)
            return try await operation()
        }
    }
}

extension Task where Failure == Never {
    static func delayed(
        byTimeInterval delayInterval: TimeInterval,
        priority: TaskPriority? = nil,
        operation: @escaping @Sendable () async -> Success
    ) -> Task {
        Task(priority: priority) {
            let delay = UInt64(delayInterval * 1_000_000_000)
            try? await Task<Never, Never>.sleep(nanoseconds: delay)
            return await operation()
        }
    }
}
