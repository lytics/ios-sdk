//
//  Millisecond.swift
//
//  Created by Mathew Gacy on 10/21/22.
//

import Foundation

/// The number of milliseconds between 00:00:00 UTC on 1 January 1970 and an event.
public typealias Millisecond = Int64

extension Millisecond {
    static var minute: Self {
        60_000
    }
}
