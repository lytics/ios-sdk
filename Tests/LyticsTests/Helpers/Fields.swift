//
//  Fields.swift
//
//  Created by Mathew Gacy on 10/25/22.
//

import Lytics
import Foundation

enum Stream {
    /// stream_1.
    static let one = "stream_1"
    /// stream_2.
    static let two = "stream_2"
    /// stream_3.
    static let three = "stream_3"
}

enum Name {
    /// name_1.
    static let one = "name_1"
    /// name_2.
    static let two = "name_2"
    /// name_3.
    static let three = "name_3"
}

enum Timestamp {
    /// 1_666_000_000_000.
    static let one: Millisecond =  1_666_000_000_000
    /// 1_666_000_001_000.
    static let two: Millisecond = 1_666_000_001_000
    /// 1_666_000_002_500.
    static let three: Millisecond = 1_666_000_002_500
}
