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
            idfaProvider: { nil },
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
                    ] as [String: Any]
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
                    ] as [String: Any]
                ],
                attributes: [
                    "firstName": User1.firstName,
                    "titles": User1.titles
                ]
            )
        )
    }

    func testUpdateIdentifiersError() async throws {
        let anonymousIdentityKey = "_uid"

        var storedIdentifiers: [String: Any]? = [anonymousIdentityKey: Mock.uuidString]
        var storedAttributes: [String: Any]?
        let storage = UserStorage.mock(
            attributes: { storedAttributes },
            identifiers: { storedIdentifiers },
            storeAttributes: { storedAttributes = $0 },
            storeIdentifiers: { storedIdentifiers = $0 }
        )

        let sut = UserManager(
            configuration: .init(anonymousIdentityKey: anonymousIdentityKey),
            encoder: .init(),
            idfaProvider: { nil },
            idProvider: { Mock.uuidString },
            storage: storage
        )

        let errorExpectation = expectation(description: "Error caught")
        var caughtError: EncodingError!
        do {
            _ = try await sut.update(
                with: UserUpdate(
                    identifiers: 1,
                    attributes: .never
                ))
        } catch let encodingError as EncodingError {
            caughtError = encodingError
            errorExpectation.fulfill()
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }

        await fulfillment(of: [errorExpectation], timeout: expectationTimeout)
        XCTAssertEqual(caughtError!.userDescription, "Unable to create a dictionary from 1.")
    }

    func testApply() async throws {
        let anonymousIdentityKey = "_uid"
        let a = 1
        let b = "2"

        var storedIdentifiers: [String: Any]? = [anonymousIdentityKey: Mock.uuidString]
        var storedAttributes: [String: Any]?
        let storage = UserStorage.mock(
            attributes: { storedAttributes },
            identifiers: { storedIdentifiers },
            storeAttributes: { storedAttributes = $0 },
            storeIdentifiers: { storedIdentifiers = $0 }
        )

        let sut = UserManager(
            configuration: .init(anonymousIdentityKey: anonymousIdentityKey),
            encoder: .init(),
            idfaProvider: { nil },
            idProvider: { Mock.uuidString },
            storage: storage
        )

        try await sut.apply(
            UserUpdate(
                identifiers: TestIdentifiers(
                    email: User1.email,
                    userID: User1.userID,
                    nested: .init(a: a, b: b)
                ),
                attributes: .never
            ))

        XCTAssertNil(storedAttributes)
        Assert.identifierEquality(
            storedIdentifiers!,
            expected: [
                anonymousIdentityKey: Mock.uuidString,
                "email": User1.email,
                "userID": User1.userID,
                "nested": [
                    "a": a,
                    "b": b
                ] as [String: Any]
            ]
        )

        try await sut.apply(
            UserUpdate(
                identifiers: .never,
                attributes: TestAttributes(
                    firstName: User1.firstName,
                    titles: User1.titles
                )
            )
        )

        Assert.attributeEquality(
            storedAttributes!,
            expected: [
                "firstName": User1.firstName,
                "titles": User1.titles
            ]
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

        let sut = UserManager(
            encoder: .init(),
            idfaProvider: { nil },
            storage: storage
        )

        try await sut.updateIdentifiers(with: User1.identifiers)

        await fulfillment(of: [storeExpectation], timeout: expectationTimeout)
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

        let sut = UserManager(
            encoder: .init(),
            idfaProvider: { nil },
            storage: storage
        )

        try await sut.updateAttributes(with: User1.attributes)

        await fulfillment(of: [storeExpectation], timeout: expectationTimeout)
        Assert.attributeEquality(storedAttributes, expected: User1.anyAttributes)
    }

    func testLoadStoredOnInit() async throws {
        let expectedAttributes = User1.anyAttributes
        let expectedIdentifiers = User1.anyIdentifiers
        let storage = UserStorage.mock(
            attributes: { expectedAttributes },
            identifiers: { expectedIdentifiers }
        )

        let sut = UserManager(
            encoder: .init(),
            idfaProvider: { nil },
            storage: storage
        )

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
            idfaProvider: { nil },
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
            idfaProvider: { nil },
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
            idfaProvider: { nil },
            idProvider: { initialIdentityValue },
            storage: storage
        )

        _ = UserManager(
            configuration: .init(anonymousIdentityKey: updatedIdentityKey),
            encoder: .init(),
            idfaProvider: { nil },
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

    func testIDFAIsAdded() async {
        let expectedIDFA = "11111111-1111-1111-1111-111111111111"
        let expectedIdentifiers: [String: String] = [
            Constants.defaultAnonymousIdentityKey: Mock.uuidString,
            Constants.idfaKey: expectedIDFA
        ]

        let idfaProvider: () -> String? = {
            expectedIDFA
        }

        var storedIdentifiers: [String: Any]! = [Constants.defaultAnonymousIdentityKey: Mock.uuidString]
        let storage = UserStorage.mock(
            identifiers: { storedIdentifiers },
            storeIdentifiers: { storedIdentifiers = $0 }
        )

        let sut = UserManager(
            configuration: .init(),
            encoder: .init(),
            idfaProvider: idfaProvider,
            idProvider: { Mock.uuidString },
            storage: storage
        )

        let actualIdentifiers = await sut.identifiers
        XCTAssertEqual(actualIdentifiers as! [String: String], expectedIdentifiers)
    }

    func testIDFAIsPreserved() async throws {
        let expectedIDFA = "11111111-1111-1111-1111-111111111111"
        let expectedIdentifiers: [String: String] = [
            Constants.defaultAnonymousIdentityKey: Mock.uuidString,
            Constants.idfaKey: expectedIDFA
        ]

        let idfaProvider: () -> String? = {
            expectedIDFA
        }

        var storedIdentifiers: [String: Any]! = [Constants.defaultAnonymousIdentityKey: Mock.uuidString]
        let storage = UserStorage.mock(
            identifiers: { storedIdentifiers },
            storeIdentifiers: { storedIdentifiers = $0 }
        )

        let sut = UserManager(
            configuration: .init(),
            encoder: .init(),
            idfaProvider: idfaProvider,
            idProvider: { Mock.uuidString },
            storage: storage
        )

        let userUpdate: [String: AnyCodable] = [Constants.idfaKey: "mutated"]
        try await sut.updateIdentifiers(with: userUpdate)

        let actualIdentifiers = await sut.identifiers
        XCTAssertEqual(actualIdentifiers as! [String: String], expectedIdentifiers)
    }

    func testRemoveIdentifier() async {
        let expectedIdentifiers: [String: Any] = [
            "email": "someemail@lytics.com",
            "userID": 1_234,
            "nested": [
                "a": 1
            ]
        ]

        var storedIdentifiers: [String: Any]! = User1.anyIdentifiers
        let storage = UserStorage.mock(
            identifiers: { storedIdentifiers },
            storeIdentifiers: { storedIdentifiers = $0 }
        )

        let sut = UserManager(
            configuration: .init(),
            encoder: .init(),
            idfaProvider: { nil },
            idProvider: { Mock.uuidString },
            storage: storage
        )

        await sut.removeIdentifier("nested.b")

        Assert.identifierEquality(storedIdentifiers, expected: expectedIdentifiers)
    }

    func testRemoveAttribute() async {
        let expectedAttributes: [String: Any] = [
            "firstName": "Jane"
        ]

        var storedAttributes: [String: Any]? = User1.anyAttributes
        let storage = UserStorage.mock(
            attributes: { storedAttributes },
            storeAttributes: { storedAttributes = $0 }
        )

        let sut = UserManager(
            configuration: .init(),
            encoder: .init(),
            idfaProvider: { nil },
            idProvider: { Mock.uuidString },
            storage: storage
        )

        await sut.removeAttribute("titles")

        Assert.attributeEquality(storedAttributes!, expected: expectedAttributes)
    }

    func testClear() async {
        let anonymousIdentityKey = "id"

        var storedAttributes: [String: Any]? = ["initial": "value"]
        var storedIdentifiers: [String: Any]!
        let attributeExpectation = expectation(description: "Attributes were stored")
        let identifierExpectation = expectation(description: "Identifiers were stored")
        let storage = UserStorage.mock(
            identifiers: { [anonymousIdentityKey: "initial_value"] },
            storeAttributes: { attributes in
                storedAttributes = attributes
                attributeExpectation.fulfill()
            },
            storeIdentifiers: { identifiers in
                storedIdentifiers = identifiers
                identifierExpectation.fulfill()
            }
        )

        let sut = UserManager(
            configuration: .init(anonymousIdentityKey: anonymousIdentityKey),
            encoder: .init(),
            idfaProvider: { nil },
            idProvider: { Mock.uuidString },
            storage: storage
        )

        await sut.clear()
        await fulfillment(of: [attributeExpectation, identifierExpectation], timeout: expectationTimeout)

        XCTAssertNil(storedAttributes)
        XCTAssertEqual(storedIdentifiers.count, 1)
        let storedID = storedIdentifiers[anonymousIdentityKey] as! String
        XCTAssertEqual(storedID, Mock.uuidString)
    }

    func testGetUser() async {
        let anonymousIdentityKey = "userID"
        let attributes: [String: Any] = User1.anyAttributes
        let identifiers: [String: Any] = User1.anyIdentifiers

        let attributeExpectation = expectation(description: "Attributes were fetched")
        let storage = UserStorage.mock(
            attributes: {
                attributeExpectation.fulfill()
                return attributes
            },
            identifiers: {
                identifiers
            }
        )

        let sut = UserManager(
            configuration: .init(anonymousIdentityKey: anonymousIdentityKey),
            encoder: .init(),
            idfaProvider: { nil },
            storage: storage
        )

        let actualUser = await sut.user
        await fulfillment(of: [attributeExpectation], timeout: expectationTimeout)

        XCTAssertEqual(
            actualUser,
            LyticsUser(
                identifiers: User1.identifiers,
                attributes: User1.attributes
            )
        )
    }
}
