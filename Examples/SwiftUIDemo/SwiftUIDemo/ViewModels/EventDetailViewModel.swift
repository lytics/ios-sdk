//
//  EventDetailViewModel.swift
//  SwiftUIDemo
//
//  Created by Mathew Gacy on 10/24/22.
//  Copyright © 2022 Lytics. All rights reserved.
//

import Foundation
import SwiftUI

final class EventDetailViewModel: ObservableObject {
    private let eventService: EventService
    private let event: Event
    @Published private(set) var title: String
    @Published private(set) var subtitle: String
    @Published private(set) var details: String
    @Published private(set) var imageURL: URL

    init(eventService: EventService, event: Event) {
        self.eventService = eventService
        self.event = event
        self.title = event.artist.name
        self.subtitle = event.dateTime
        self.details = event.details
        self.imageURL = event.imageURL
    }

    func onAppear() {
        print("\(#function)")
    }

    func buyTickets() {
        print("\(#function)")
    }
}
