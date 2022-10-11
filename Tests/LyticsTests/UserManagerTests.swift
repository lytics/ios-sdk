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

    func testUpdate() async throws {
        let a = 1
        let b = "2"

        let sut = UserManager()

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
}
