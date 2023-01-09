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

    private let strategy: (Error, Int) -> Strategy

    init(strategy: @escaping (Error, Int) -> Strategy) {
        self.strategy = strategy
    }

    func strategy(for error: Error, retryCount: Int) -> Strategy {
        strategy(error, retryCount)
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

extension RequestFailureHandler {
    static func live(
        maxRetryCount: Int,
        initialDelay: TimeInterval = 10,
        delayMultiplier: Double = 1
    ) -> Self {
        .init(
            strategy: { error, retryCount in
                switch error {
                case is DecodingError:
                    return .discard("Invalid response value")
                case NetworkError.clientError:
                    return .discard(error.localizedDescription)
                default: break
                }

                if retryCount < maxRetryCount {
                    let delay = Self.calculateDelay(
                        currentAttempt: retryCount + 1,
                        initialDelay: initialDelay,
                        delayMultiplier: delayMultiplier
                    )

                    return .retry(delay)
                } else {
                    return .store
                }
            })
    }
}
