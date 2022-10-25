//
//  SwiftUIDemoApp.swift
//  SwiftUIDemo
//
//  Created by Mathew Gacy on 10/1/22.
//  
//

import Lytics
import SwiftUI

@main
struct SwiftUIDemoApp: App {
    init() {
        Lytics.shared.start { configuration in
            configuration.apiKey = "at.xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
            configuration.maxQueueSize = 5
            configuration.logLevel = .debug
            // ...
        }
    }

    var body: some Scene {
        WindowGroup {
            TabContainerView(
                eventService: .mock)
        }
    }
}
