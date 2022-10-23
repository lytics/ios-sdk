//
//  Storage.swift
//
//  Created by Mathew Gacy on 10/23/22.
//

import Foundation

struct Storage {
    var write: (Data) throws -> Void
    var read: () throws -> Data?
    var clear: () throws -> Void
}

extension Storage {
    func save<T: Encodable>(_ object: T, encodingWith encoder: JSONEncoder = .init()) throws {
        do {
            let data = try encoder.encode(object)
            try write(data)
        } catch {
            throw StorageError(underlyingError: error)
        }
    }

    func read<T: Decodable>(decodingWith decoder: JSONDecoder = .init()) throws -> T? {
        guard let data = try read() else {
            return nil
        }
        do {
            let object = try decoder.decode(T.self, from: data)
            return object
        } catch {
            throw StorageError(underlyingError: error)
        }
    }
}

extension Storage {
    static func live(file: File) throws -> Self {
        let fileManager = FileManager.default
        try fileManager.createDirectory(for: file)

        return Storage(
            write: { data in
                do {
                    try fileManager.createDirectory(at: file.directory, withIntermediateDirectories: true)
                    try data.write(to: file.url, options: .atomic)
                } catch {
                    throw StorageError.file(path: file.path, error: error)
                }
            },
            read: {
                do {
                    return try Data(contentsOf: file.url)
                } catch CocoaError.Code.fileReadNoSuchFile {
                    return nil
                } catch {
                    throw StorageError.file(path: file.path, error: error)
                }
            },
            clear: {
                do {
                    try fileManager.removeItem(at: file.url)
                } catch CocoaError.Code.fileNoSuchFile {
                    return
                } catch {
                    throw StorageError.file(path: file.path, error: error)
                }
            })
    }
}
