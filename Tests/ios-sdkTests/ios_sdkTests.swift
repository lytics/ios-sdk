import XCTest
@testable import ios_sdk

final class ios_sdkTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Lytics().text, "Hello, World!")
    }
}
