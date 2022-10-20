//
//  TestCart.swift
//
//  Created by Mathew Gacy on 10/17/22.
//

import Foundation

struct TestCart: Codable, Equatable {
    var orderId: String
    var total: Float
}

extension TestCart {
    static var user1: Self {
        .init(
            orderId: "some-order-id",
            total: 19.95)
    }
}
