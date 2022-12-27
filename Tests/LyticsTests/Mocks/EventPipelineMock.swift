//
//  EventPipelineMock.swift
//
//  Created by Mathew Gacy on 11/16/22.
//

import Foundation
@testable import Lytics

struct EventPipelineMock: EventPipelineProtocol {
    var onEvent: (String?, Millisecond, String?, Any) -> Void = { _, _, _, _ in }
    var onOptIn: () -> Void = {}
    var onOptOut: () -> Void = {}
    var onDispatch: () -> Void = {}
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
