//
//  StorageTests.swift
//
//  Created by Mathew Gacy on 1/16/23.
//

@testable import Lytics
import XCTest

final class StorageTests: XCTestCase {
    var file: File = {
        let directory = try! FileManager.default.permanentURL(
            subdirectory: Constants.requestStorageDirectory
        )
        let file = File(directory: directory, name: "test")
        return file
    }()

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        do {
            try FileManager.default.removeItem(at: file.url)
        } catch CocoaError.Code.fileNoSuchFile {
            return
        } catch {
            throw error
        }
    }

    func testWriteData() throws {
        let sut = try Storage.live(file: file)
        let data = Data(Date().description.utf8)
        try sut.write(data)

        let actual = try Data(contentsOf: file.url)
        XCTAssertEqual(actual, data)
    }

    func testSave() throws {
        let sut = try Storage.live(file: file)
        try sut.save(TestIdentifiers.user1)

        let actual = try JSONDecoder().decode(TestIdentifiers.self, from: try Data(contentsOf: file.url))
        XCTAssertEqual(actual, TestIdentifiers.user1)
    }

    func testReadData() throws {
        try FileManager.default.createDirectory(at: file.directory, withIntermediateDirectories: true)
        let data = Data(Date().description.utf8)
        try data.write(to: file.url)

        let sut = try Storage.live(file: file)
        let actual = try sut.read()
        XCTAssertEqual(actual, data)
    }

    func testReadMissingData() throws {
        let sut = try Storage.live(file: file)
        let actual = try sut.read()
        XCTAssertNil(actual)
    }

    func testRead() throws {
        try FileManager.default.createDirectory(at: file.directory, withIntermediateDirectories: true)
        let data = try JSONEncoder.sorted.encode(TestConsent.user1)
        try data.write(to: file.url)

        let sut = try Storage.live(file: file)
        let actual: TestConsent? = try sut.read()
        XCTAssertEqual(actual, TestConsent.user1)
    }

    func testClear() throws {
        let sut = try Storage.live(file: file)
        let data = Data(Date().description.utf8)

        try sut.write(data)
        XCTAssert(FileManager.default.fileExists(atPath: file.path))

        try sut.clear()

        XCTAssertFalse(FileManager.default.fileExists(atPath: file.path))

        try sut.clear()
    }
}
