//
//  EventService.swift
//  SwiftUIDemo
//
//  Created by Mathew Gacy on 10/24/22.
//  Copyright © 2022 Lytics. All rights reserved.
//

import Foundation
import SwiftUI

struct EventService {
    var localEvents: () throws -> [Event]
    var events: () throws -> [Event]
    var image: (URL) -> Image
}

extension EventService {
    static var mock: Self {
        .init(
            localEvents: {
                [.mock]
            },
            events: {
                guard let eventsData = try Bundle.main.loadJSON(
                    filename: Constants.eventsJSONFilename) else {
                    return []
                }
                return try JSONDecoder().decode([Event].self, from:  eventsData)
            },
            image: { url in
                switch url.lastPathComponent {
                case "3":
                    return .image3
                case "4":
                    return .image4
                case "5":
                    return .image5
                default:
                    return .image2
                }
            })
    }
}
