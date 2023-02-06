//
//  EventPipelineMock.swift
//
//  Created by Mathew Gacy on 11/16/22.
//

import Foundation
@testable import Lytics
import XCTest

struct EventPipelineMock: EventPipelineProtocol {
    var onEvent: (String?, Millisecond, String?, Any) -> Void = { _, _, _, _ in XCTFail("\(Self.self).onEvent") }
    var onOptIn: () -> Void = { XCTFail("\(Self.self).onOptIn") }
    var onOptOut: () -> Void = { XCTFail("\(Self.self).onOptOut") }
    var onDispatch: () -> Void = { XCTFail("\(Self.self).onDispatch") }
    var isOptedIn: Bool = true

    func event<E>(
        stream: String?,
        timestamp: Millisecond,
        name: String?,
        event: E
    ) async where E: Encodable {
        onEvent(stream, timestamp, name, event)
    }

    func optIn() {
        onOptIn()
    }

    func optOut() {
        onOptOut()
    }

    func dispatch() async {
        onDispatch()
    }
}
