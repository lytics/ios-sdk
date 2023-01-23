//
//  UserStorageTests.swift
//
//  Created by Mathew Gacy on 1/16/23.
//

@testable import Lytics
import XCTest

final class UserStorageTests: XCTestCase {
    let attributes = User1.anyAttributes
    let identifiers = User1.anyIdentifiers

    override func tearDownWithError() throws {
        let defaults = UserDefaults()
        let emptyValue: [String: Any]? = nil
        defaults.set(emptyValue, for: .userAttributes)
        defaults.set(emptyValue, for: .userIdentifiers)
    }

    func testReadAttributes() {
        let defaults = UserDefaults()
        defaults.set(attributes, for: .userAttributes)

        let sut = UserStorage.live(userDefaults: defaults)
        let actual = sut.attributes()
        Assert.attributeEquality(actual!, expected: attributes)
    }

    func testWriteAttributes() {
        let defaults = UserDefaults()

        let sut = UserStorage.live(userDefaults: defaults)
        sut.storeAttributes(attributes)

        let actual = defaults.dictionary(for: .userAttributes)
        Assert.attributeEquality(actual!, expected: attributes)
    }

    func testReadIdentifiers() {
        let defaults = UserDefaults()
        defaults.set(identifiers, for: .userIdentifiers)

        let sut = UserStorage.live(userDefaults: defaults)
        let actual = sut.identifiers()
        Assert.identifierEquality(actual!, expected: identifiers)
    }

    func testWriteIdentifiers() {
        let defaults = UserDefaults()

        let sut = UserStorage.live(userDefaults: defaults)
        sut.storeIdentifiers(identifiers)

        let actual = defaults.dictionary(for: .userIdentifiers)
        Assert.identifierEquality(actual!, expected: identifiers)
    }
}
