//
//  EncodingError+Description.swift
//
//  Created by Mathew Gacy on 1/16/23.
//

import Foundation

extension EncodingError {

    /// Return a string with a human readable reason for json encoding failure.
    var userDescription: String {
        switch self {
        case .invalidValue(_, let context):
            return context.debugDescription
        @unknown default:
            return localizedDescription
        }
    }
}
