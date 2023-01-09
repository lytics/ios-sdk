//
//  RequestFailureHandler.swift
//
//  Created by Mathew Gacy on 10/16/22.
//

import Foundation

struct RequestFailureHandler {

    enum Strategy: Equatable {
        /// Discard a request that failed due to an unrecoverable error.
        case discard(_ reason: String)
        /// Retry the request in `delay` seconds.
        case retry(_ delay: TimeInterval)
        /// Store the request to retry later.
        case store
    }

    struct RetryConfiguration {
        let maxRetryCount: Int
        let initialDelay: TimeInterval
        let delayMultiplier: Double
    }

    let configuration: RetryConfiguration

    func strategy(for error: Error, retryCount: Int) -> Strategy {
        switch error {
        case is DecodingError:
            return .discard("Invalid response value")
        case NetworkError.clientError:
            return .discard(error.localizedDescription)
        default: break
        }

        if retryCount < configuration.maxRetryCount {
            let delay = Self.calculateDelay(
                currentAttempt: retryCount + 1,
                initialDelay: configuration.initialDelay,
                delayMultiplier: configuration.delayMultiplier
            )

            return .retry(delay)
        } else {
            return .store
        }
    }

    private static func calculateDelay(
        currentAttempt: Int,
        initialDelay: TimeInterval,
        delayMultiplier: Double
    ) -> TimeInterval {
        currentAttempt == 1
            ? initialDelay
            : initialDelay * pow(1 + delayMultiplier, Double(currentAttempt - 1))
    }
}

extension RequestFailureHandler.RetryConfiguration {
    static func live(maxRetryCount: Int) -> Self {
        .init(
            maxRetryCount: maxRetryCount,
            initialDelay: 10,
            delayMultiplier: 1
        )
    }
}

extension RequestFailureHandler {
    static func live(maxRetryCount: Int) -> Self {
        .init(
            configuration: .live(
                maxRetryCount: maxRetryCount))
    }
}
