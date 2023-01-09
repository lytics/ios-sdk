//
//  FileManager+Utils.swift
//
//  Created by Mathew Gacy on 10/22/22.
//

import Foundation

extension FileManager {

    /// Creates directory with the specified attributes for the given file.
    /// - Parameters:
    ///   - file: A file that specifies the parent directory to create.
    ///   - attributes: The file attributes for the new directory.
    func createDirectory(
        for file: File,
        attributes: [FileAttributeKey: Any]? = nil
    ) throws {
        try createDirectory(
            at: file.directory,
            withIntermediateDirectories: true,
            attributes: attributes
        )
    }
}

extension FileManager {

    /// Returns the URL of a subdirectory in the user's Caches directory.
    /// - Parameter subdirectory: The optional name of a subdirectory in the Caches directory.
    /// - Returns: The directory URL.
    func temporaryURL(subdirectory: String? = nil) throws -> URL {
        guard let baseURL = urls(for: .cachesDirectory, in: .userDomainMask).first else {
            throw StorageError.directoryNotFound(name: "Caches")
        }

        var directoryURL = baseURL.appendingPathComponent(Constants.baseDirectory)
        if let subdirectory {
            directoryURL.appendPathComponent(subdirectory, isDirectory: true)
        }

        return directoryURL
    }

    /// Returns the URL of a subdirectory in the user's Document directory.
    /// - Parameter subDirectory: The optional name of a subdirectory in the Document directory.
    /// - Returns: The directory URL.
    func permanentURL(subdirectory: String? = nil) throws -> URL {
        guard let baseURL = urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw StorageError.directoryNotFound(name: "Documents")
        }

        var directoryURL = baseURL.appendingPathComponent(Constants.baseDirectory)
        if let subdirectory {
            directoryURL.appendPathComponent(subdirectory, isDirectory: true)
        }

        return directoryURL
    }
}
