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
            })
    }
}
