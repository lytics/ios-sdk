//
//  StorageError.swift
//
//  Created by Mathew Gacy on 10/23/22.
//

import Foundation

enum StorageError: Error {
    case encoding(EncodingError)
    case decoding(DecodingError)
    case file(path: String, error: Error)
    case directoryNotFound(name: String)

    init(underlyingError: Error, path: String = "") {
        switch underlyingError {
        case let error as EncodingError:
            self = .encoding(error)
        case let error as DecodingError:
            self = .decoding(error)
        case let error as StorageError:
            self = error
        default:
            self = .file(path: path, error: underlyingError)
        }
    }

    var localizedDescription: String {
        switch self {
        case let .encoding(error):
            return error.localizedDescription
        case let .decoding(error):
            return error.localizedDescription
        case let .file(path: path, error: error):
            return "Operation on \(path) failed: \(error.localizedDescription)"
        case let .directoryNotFound(name):
            return "Unable to find \(name) directory."
        }
    }
}
