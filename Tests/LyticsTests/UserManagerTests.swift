//
//  UserManagerTests.swift
//
//  Created by Mathew Gacy on 9/29/22.
//

@testable import Lytics
import AnyCodable
import Foundation
import XCTest

final class UserManagerTests: XCTestCase {
    let expectationTimeout: TimeInterval = 0.1

    func testUpdate() async throws {
        let a = 1
        let b = "2"

        let sut = UserManager(
            encoder: .init(),
            storage: .mock())

        let firstResult = try await sut.update(
            with: UserUpdate(
                identifiers: TestIdentifiers(email: User1.email),
                attributes: .never))

        XCTAssertEqual(
            firstResult,
            LyticsUser(
                identifiers: [
                    "email": User1.email
                ])
        )

        let secondResult = try await sut.update(
            with: UserUpdate(
                identifiers: TestIdentifiers(userID: User1.userID),
                attributes: .never))

        XCTAssertEqual(
            secondResult,
            LyticsUser(
                identifiers: [
                    "email": User1.email,
                    "userID": User1.userID
                ])
        )

        let thirdResult = try await sut.update(
            with: UserUpdate(
                identifiers: TestIdentifiers(nested: .init(a: a, b: b)),
                attributes: TestAttributes(firstName: User1.firstName)))

        XCTAssertEqual(
            thirdResult,
            LyticsUser(
                identifiers: [
                    "email": User1.email,
                    "userID": User1.userID,
                    "nested": [
                        "a": a,
                        "b": b
                    ]
                ],
                attributes: [
                    "firstName": User1.firstName
                ])
        )

        let fourthResult = try await sut.update(
            with: UserUpdate(
                identifiers: .never,
                attributes: TestAttributes(titles: User1.titles)))

        XCTAssertEqual(
            fourthResult,
            LyticsUser(
                identifiers: [
                    "email": User1.email,
                    "userID": User1.userID,
                    "nested": [
                        "a": a,
                        "b": b
                    ]
                ],
                attributes: [
                    "firstName": User1.firstName,
                    "titles": User1.titles
                ])
        )
    }

    func testUpdateIdentifiersStorage() async throws {
        var storage = UserStorage.mock()

        var storedIdentifiers: [String: Any]!
        let storeExpectation = expectation(description: "Identifiers were stored")
        storage.storeIdentifiers = { identifiers in
            storedIdentifiers = identifiers
            storeExpectation.fulfill()
        }

        let sut = UserManager(encoder: .init(), storage: storage)

        try await sut.updateIdentifiers(with: User1.identifiers)

        await waitForExpectations(timeout: expectationTimeout)
        Assert.identifierEquality(storedIdentifiers, expected: User1.anyIdentifiers)
    }

    func testUpdateAttributesStorage() async throws {
        var storedAttributes: [String: Any]!
        let storeExpectation = expectation(description: "Attributes were stored")
        let storage = UserStorage.mock(
            storeAttributes: { attributes in
                storedAttributes = attributes
                storeExpectation.fulfill()
            }
        )

        let sut = UserManager(encoder: .init(), storage: storage)

        try await sut.updateAttributes(with: User1.attributes)

        await waitForExpectations(timeout: expectationTimeout)
        Assert.attributeEquality(storedAttributes, expected: User1.anyAttributes)
    }

    func testLoadStoredOnInit() async throws {
        let expectedAttributes = User1.anyAttributes
        let expectedIdentifiers = User1.anyIdentifiers
        let storage = UserStorage.mock(
            attributes: { expectedAttributes },
            identifiers: { expectedIdentifiers }
        )

        let sut = UserManager(encoder: .init(), storage: storage)

        let attributes = await sut.attributes
        let identifiers = await sut.identifiers

        Assert.attributeEquality(attributes, expected: expectedAttributes)
        Assert.identifierEquality(identifiers, expected: expectedIdentifiers)
    }
}
