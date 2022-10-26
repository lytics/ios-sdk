//
//  EventDetailViewModel.swift
//  SwiftUIDemo
//
//  Created by Mathew Gacy on 10/24/22.
//  Copyright © 2022 Lytics. All rights reserved.
//

import Foundation
import SwiftUI

final class EventDetailViewModel:  ObservableObject {
    private let eventService: EventService
    private let event: Event
    @Published private(set) var title: String
    @Published private(set) var subtitle: String
    @Published private(set) var details: String
    @Published private(set) var image: Image?

    internal init(
        eventService: EventService,
        event: Event,
        title: String = "",
        subtitle: String = "",
        details: String = ""
    ) {
        self.eventService = eventService
        self.event = event
        self.title = title
        self.subtitle = subtitle
        self.details = details
    }

    init(eventService: EventService, event: Event) {
        self.eventService = eventService
        self.event = event
        self.title = event.artist
        self.subtitle = event.dateTime
        self.details = event.details
    }

    func fetchImage() {
        image = eventService.image(event.imageURL)
    }

    func buyTickets() {
        print("\(#function)")
    }
}
