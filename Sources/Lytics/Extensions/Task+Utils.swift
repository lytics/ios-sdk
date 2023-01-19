//
//  Task+Utils.swift
//
//  Created by Mathew Gacy on 10/4/22.
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

    // https://www.swiftbysundell.com/articles/retrying-an-async-swift-task/
    @discardableResult
    static func retrying(
        priority: TaskPriority? = nil,
        maxRetryCount: Int = 3,
        shouldRetry: @escaping @Sendable (Error) -> Bool = { _ in true },
        operation: @escaping @Sendable () async throws -> Success
    ) -> Task {
        Task(priority: priority) {
            for _ in 0 ..< maxRetryCount {
                try Task<Never, Never>.checkCancellation()

                do {
                    return try await operation()
                } catch {
                    guard shouldRetry(error) else {
                        throw error
                    }
                    continue
                }
            }

            try Task<Never, Never>.checkCancellation()
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
