//
//  XCTestCase+Utils.swift
//
//  Created by Mathew Gacy on 4/5/23.
//

import XCTest

#if swift(<5.8)
extension XCTestCase {
    /// Waits on a group of expectations for up to the specified timeout, optionally enforcing their order of fulfillment.
    ///
    /// This allows use of Xcode 14.3's `XCTestCase.fulfillment(of:timeout:enforceOrder:)` method while maintaining
    /// compatibility with previous versions.
    ///
    /// - Parameters:
    ///   - expectations: An array of expectations the test must satisfy.
    ///   - seconds: The time, in seconds, the test allows for the fulfillment of the expectations. The default timeout
    ///   allows the test to run until it reaches its execution time allowance.
    ///   - enforceOrderOfFulfillment: If `true`, the test must satisfy the expectations in the order they appear in
    ///   the array.
    func fulfillment(
        of expectations: [XCTestExpectation],
        timeout seconds: TimeInterval = .infinity,
        enforceOrder enforceOrderOfFulfillment: Bool = false
    ) async {
        await MainActor.run {
            wait(for: expectations, timeout: seconds, enforceOrder: enforceOrderOfFulfillment)
        }
    }
}
#endif
