//
//  LyticsError.swift
//
//  Created by Mathew Gacy on 10/21/22.
//

import Foundation

struct LyticsError: Error {
    var reason: String
    var underlyingError: Error?
}

extension LyticsError {
    init(_ error: Error) {
        self.reason = error.localizedDescription
        self.underlyingError = error
    }
}
