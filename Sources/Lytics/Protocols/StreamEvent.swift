//
//  StreamEvent.swift
//
//  Created by Mathew Gacy on 10/6/22.
//

import Foundation

/// A class of types to be added to an event stream.
protocol StreamEvent: Encodable {

    /// The stream to which the event is destined.
    var stream: String { get }

    /// The event name.
    var name: String? { get }
}
