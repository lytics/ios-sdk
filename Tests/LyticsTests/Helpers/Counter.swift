//
//  Counter.swift
//
//  Created by Mathew Gacy on 1/16/23.
//

import Foundation

actor Counter {
    private(set) var count: Int = 0

    @discardableResult
    func increment() -> Int {
        count += 1
        return count
    }
}
