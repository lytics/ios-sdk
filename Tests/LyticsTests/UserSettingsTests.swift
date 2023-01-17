//
//  UserSettingsTests.swift
//
//  Created by Mathew Gacy on 1/16/23.
//

@testable import Lytics
import XCTest

final class UserSettingsTests: XCTestCase {

    func testReadOptIn() {
        let expected = true

        let defaults = UserDefaults()
        defaults.set(expected, for: .didOptIn)

        let sut = UserSettings.live(userDefaults: defaults)

        let actual = sut.getOptIn()
        XCTAssertEqual(actual, expected)
    }

    func testWriteOptIn() {
        let expected = false

        let defaults = UserDefaults()

        let sut = UserSettings.live(userDefaults: defaults)
        sut.setOptIn(expected)

        let actual = defaults.bool(for: .didOptIn)
        XCTAssertEqual(actual, expected)
    }


//    func readOptIn() {
//        let expected = false
//
//        let defaults = UserDefaults()
//
//        let sut = UserSettings.live(userDefaults: defaults)
//        sut.setOptIn(expected)
//
//        let actual = defaults.bool(for: .didOptIn)
//        XCTAssertEqual(actual, expected)
//    }
//
//    func testWriteOptIn() {
//        let expected = true
//
//        let defaults = UserDefaults()
//        defaults.set(expected, for: .didOptIn)
//
//        let sut = UserSettings.live(userDefaults: defaults)
//
//        let actual = sut.getOptIn()
//        XCTAssertEqual(actual, expected)
//    }
}
