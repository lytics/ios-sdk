//
//  Event.swift
//  SwiftUIDemo
//
//  Created by Mathew Gacy on 10/24/22.
//  Copyright © 2022 Lytics. All rights reserved.
//

import Foundation

struct Event: Codable, Equatable, Hashable, Identifiable {
    var id: Int
    var artist: String
    var dateTime: String
    var details: String
    var location: String
    var imageURL: URL
}

extension Event {
    static var mock: Self {
        .init(
            id: 1,
            artist: "Maroon 5",
            dateTime: "March 18th @ 8 P.M.",
            details: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam eu ante at turpis blandit eleifend. Suspendisse potenti. Aenean et lacus sed urna tincidunt fermentum ut at elit. Praesent a augue lorem. Orci varius natoque penatibus et magnis dis parturient montes.",
            location: "Dallas, TX",
            imageURL: URL(string: "https://events.com/2")!)
    }
}
