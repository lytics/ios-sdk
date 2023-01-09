//
//  UserManagerTests.swift
//
//  Created by Mathew Gacy on 9/29/22.
//

import AnyCodable
import Foundation
@testable import Lytics
import XCTest

final class UserManagerTests: XCTestCase {
    let expectationTimeout: TimeInterval = 0.1

    func testUpdate() async throws {
        let anonymousIdentityKey = "_uid"
        let a = 1
        let b = "2"

        var storedIdentifiers: [String: Any]? = [:]
        var storedAttributes: [String: Any]?
        let storage = UserStorage.mock(
            attributes: { storedAttributes },
            identifiers: { storedIdentifiers },
            storeAttributes: { storedAttributes = $0 },
            storeIdentifiers: { storedIdentifiers = $0 }
        )

        let sut = UserManager(
            encoder: .init(),
            idProvider: { Mock.uuidString },
            storage: storage
        )

        let firstResult = try await sut.update(
            with: UserUpdate(
                identifiers: TestIdentifiers(email: User1.email),
                attributes: .never
            ))

        XCTAssertEqual(
            firstResult,
            LyticsUser(
                identifiers: [
                    anonymousIdentityKey: Mock.uuidString,
                    "email": User1.email
                ])
        )

        let secondResult = try await sut.update(
            with: UserUpdate(
                identifiers: TestIdentifiers(userID: User1.userID),
                attributes: .never
            ))

        XCTAssertEqual(
            secondResult,
            LyticsUser(
                identifiers: [
                    anonymousIdentityKey: Mock.uuidString,
                    "email": User1.email,
                    "userID": User1.userID
                ])
        )

        let thirdResult = try await sut.update(
            with: UserUpdate(
                identifiers: TestIdentifiers(nested: .init(a: a, b: b)),
                attributes: TestAttributes(firstName: User1.firstName)
            ))

        XCTAssertEqual(
            thirdResult,
            LyticsUser(
                identifiers: [
                    anonymousIdentityKey: Mock.uuidString,
                    "email": User1.email,
                    "userID": User1.userID,
                    "nested": [
                        "a": a,
                        "b": b
                    ]
                ],
                attributes: [
                    "firstName": User1.firstName
                ]
            )
        )

        let fourthResult = try await sut.update(
            with: UserUpdate(
                identifiers: .never,
                attributes: TestAttributes(titles: User1.titles)
            ))

        XCTAssertEqual(
            fourthResult,
            LyticsUser(
                identifiers: [
                    anonymousIdentityKey: Mock.uuidString,
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
                ]
            )
        )
    }

    func testUpdatedIdentifiersAreStored() async throws {
        var storedIdentifiers: [String: Any]!
        let storeExpectation = expectation(description: "Identifiers were stored")
        let storage = UserStorage.mock(
            identifiers: { [Constants.defaultAnonymousIdentityKey: Mock.uuidString] },
            storeIdentifiers: { identifiers in
                storedIdentifiers = identifiers
                storeExpectation.fulfill()
            }
        )

        let sut = UserManager(encoder: .init(), storage: storage)

        try await sut.updateIdentifiers(with: User1.identifiers)

        await waitForExpectations(timeout: expectationTimeout)
        Assert.identifierEquality(storedIdentifiers, expected: User1.anyIdentifiers)
    }

    func testUpdatedAttributesAreStored() async throws {
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

        Assert.attributeEquality(attributes!, expected: expectedAttributes)
        Assert.identifierEquality(identifiers, expected: expectedIdentifiers)
    }

    func testCreateIdentifiersOnInit() async throws {
        let anonymousIdentityKey = "id"

        var storedIdentifiers: [String: Any]?
        let storage = UserStorage.mock(
            identifiers: { storedIdentifiers },
            storeIdentifiers: { storedIdentifiers = $0 }
        )

        let sut = UserManager(
            configuration: .init(anonymousIdentityKey: anonymousIdentityKey),
            encoder: .init(),
            idProvider: { Mock.uuidString },
            storage: storage
        )

        let identifiers = await sut.identifiers as! [String: String]
        XCTAssertEqual(identifiers, [anonymousIdentityKey: Mock.uuidString])
        XCTAssertEqual(storedIdentifiers?[anonymousIdentityKey]! as! String, Mock.uuidString)
    }

    func testPreserveIdentifiersOnInit() async throws {
        let anonymousIdentityKey = "id"
        let anonymousIdentityValue = "XXXXXX"

        var storedIdentifiers: [String: Any]? = [anonymousIdentityKey: anonymousIdentityValue]
        let storage = UserStorage.mock(
            identifiers: { storedIdentifiers },
            storeIdentifiers: { storedIdentifiers = $0 }
        )

        let sut = UserManager(
            configuration: .init(anonymousIdentityKey: anonymousIdentityKey),
            encoder: .init(),
            idProvider: { Mock.uuidString },
            storage: storage
        )

        let identifiers = await sut.identifiers as! [String: String]
        XCTAssertEqual(identifiers, [anonymousIdentityKey: anonymousIdentityValue])
        XCTAssertEqual(storedIdentifiers?[anonymousIdentityKey]! as! String, anonymousIdentityValue)
    }

    func testCreateIdentifiersAfterKeyChange() async throws {
        let initialIdentityKey = "id"
        let initialIdentityValue = "XXXXXX"
        let updatedIdentityKey = "anotherID"
        let updatedIdentityValue = "YYYYYY"

        var storedIdentifiers: [String: Any]?
        let storage = UserStorage.mock(
            identifiers: { storedIdentifiers },
            storeIdentifiers: { storedIdentifiers = $0 }
        )

        _ = UserManager(
            configuration: .init(anonymousIdentityKey: initialIdentityKey),
            encoder: .init(),
            idProvider: { initialIdentityValue },
            storage: storage
        )

        _ = UserManager(
            configuration: .init(anonymousIdentityKey: updatedIdentityKey),
            encoder: .init(),
            idProvider: { updatedIdentityValue },
            storage: storage
        )

        let identifiers = storedIdentifiers as! [String: String]
        XCTAssertEqual(
            identifiers,
            [
                initialIdentityKey: initialIdentityValue,
                updatedIdentityKey: updatedIdentityValue
            ]
        )
    }
}
