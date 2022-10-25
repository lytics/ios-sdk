//
//  TimeInterval+Utils.swift
//
//  Created by Mathew Gacy on 10/21/22.
//

import Foundation

public extension TimeInterval {
    var milliseconds: Millisecond {
        Millisecond((self * 1_000).rounded())
    }
}
