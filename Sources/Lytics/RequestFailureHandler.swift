//
//  RequestFailureHandler.swift
//
//  Created by Mathew Gacy on 10/16/22.
//

import Foundation

struct RequestFailureHandler {

    enum Strategy {
        /// Discard a request that failed due to an unrecoverable error.
        case discard(_ reason: String)
        /// Retry the request in `delay` seconds.
        case retry(_ delay: TimeInterval)
        /// Store the request to retry later.
        case store
    }

    func strategy(for error: Error, retryCount: Int) -> Strategy {
        // ...
        .retry(1)
    }
}

extension RequestFailureHandler {
    static func live(maxRetryCount: Int) -> Self {
        .init()
    }
}
