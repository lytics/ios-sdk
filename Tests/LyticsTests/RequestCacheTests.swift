//
//  RequestCacheTests.swift
//
//  Created by Mathew Gacy on 12/28/22.
//

import Foundation
@testable import Lytics
import XCTest

func containerJSON<R: Codable>(response: R.Type, idStrings: [String]) -> String {
    func request(_ idString: String) -> String {
        """
        "{\\"id\\":\\"\(idString)\\",\\"request\\":{\\"url\\":\\"https:\\\\\\/\\\\\\/api.lytics.io\\\\\\/collect\\\\\\/json\\\\\\/stream\\",\\"method\\":\\"POST\\"}}"
        """
    }

    let typeString = _mangledTypeName(Uploader.PendingRequest<R>.self) ?? ""
    let elements = idStrings
        .map { "\"\(typeString)\",\(request($0))" }
        .joined(separator: ",")

    return "[\(elements)]"
}

final class RequestCacheTests: XCTestCase {
    typealias PendingRequest<R: Codable> = Uploader.PendingRequest<R>

    func testIgnoreCacheEmptyRequests() throws {
        let storage = Storage(
            write: { _ in
                XCTFail("Storage.write called")
            },
            read: {
                XCTFail("Storage.read called")
                return nil
            },
            clear: {
                XCTFail("Storage.clear called")
            }
        )

        let sut = try RequestCache(storage: storage)

        let requests: [PendingRequest<DataUploadResponse>] = []
        try sut.cache(requests)
    }

    func testCacheWithEmptyExistingData() throws {
        let readExpectation = expectation(description: "Data read from storage")
        let writeExpectation = expectation(description: "Data written to storage")

        let storedData = Data("[]".utf8)
        var writtenData: Data!

        let storage = Storage(
            write: { data in
                writtenData = data
                writeExpectation.fulfill()
            },
            read: {
                readExpectation.fulfill()
                return storedData
            },
            clear: {}
        )

        let sut = try RequestCache(storage: storage)

        let requests: [PendingRequest<DataUploadResponse>] = [
            PendingRequest(
                id: Mock.uuid,
                request: Mock.request,
                retryCount: 1,
                uploadTask: nil
            )
        ]

        try sut.cache(requests)
        waitForExpectations(timeout: 0.1)

        let expectedJSON = containerJSON(
            response: DataUploadResponse.self,
            idStrings: [Mock.uuidString]
        )
        XCTAssertEqual(writtenData, Data(expectedJSON.utf8))
    }

    func testCacheWithExistingData() throws {
        let readExpectation = expectation(description: "Data read from storage")
        let writeExpectation = expectation(description: "Data written to storage")

        let storedData = Data(
            containerJSON(
                response: DataUploadResponse.self,
                idStrings: [Mock.uuidString]
            ).utf8
        )
        var writtenData: Data!

        let storage = Storage(
            write: { data in
                writtenData = data
                writeExpectation.fulfill()
            },
            read: {
                readExpectation.fulfill()
                return storedData
            },
            clear: {}
        )

        let sut = try RequestCache(storage: storage)

        let uuidString = "BBBBBBBB-BBBB-BBBB-BBBB-BBBBBBBBBBBB"
        let requests: [PendingRequest<DataUploadResponse>] = [
            PendingRequest(
                id: UUID(uuidString: uuidString)!,
                request: Mock.request,
                retryCount: 1,
                uploadTask: nil
            )
        ]

        try sut.cache(requests)
        waitForExpectations(timeout: 0.1)

        let expectedJSON = containerJSON(
            response: DataUploadResponse.self,
            idStrings: [Mock.uuidString, uuidString]
        )
        XCTAssertEqual(writtenData, Data(expectedJSON.utf8))
    }

    func testLoad() throws {
        let storage = Storage(
            write: { _ in },
            read: {
                Data(
                    containerJSON(
                        response: DataUploadResponse.self,
                        idStrings: [Mock.uuidString]
                    ).utf8
                )
            },
            clear: {}
        )

        let sut = try RequestCache(storage: storage)
        let actual = try sut.load()!
        let actualRequest = actual.first! as! Uploader.PendingRequest<DataUploadResponse>

        XCTAssertEqual(actualRequest.id, Mock.uuid)
        XCTAssertEqual(actualRequest.request, Mock.request)
        XCTAssertEqual(actualRequest.retryCount, 0)
        XCTAssertEqual(actualRequest.uploadTask, nil)
    }

    func testDeleteAll() throws {
        let clearExpectation = expectation(description: "Storage was cleared")
        let storage = Storage(
            write: { _ in },
            read: { nil },
            clear: {
                clearExpectation.fulfill()
            }
        )

        let sut = try RequestCache(storage: storage)
        try sut.deleteAll()

        waitForExpectations(timeout: 0.1)
    }
}
