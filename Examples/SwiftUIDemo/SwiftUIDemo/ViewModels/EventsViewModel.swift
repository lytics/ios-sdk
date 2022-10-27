//
//  EventsViewModel.swift
//  SwiftUIDemo
//
//  Created by Mathew Gacy on 10/24/22.
//  Copyright © 2022 Lytics. All rights reserved.
//

import Foundation

final class EventsViewModel: ObservableObject {
    private let eventService: EventService
    @Published var featuredEvent: Event?
    @Published var events: [Event]

    init(
        eventService: EventService,
        featuredEvent: Event? = nil,
        events: [Event] = []
    ) {
        self.eventService = eventService
        self.featuredEvent = featuredEvent
        self.events = events
    }

    func fetchEvents() {
        do {
            let localEvents = try eventService.localEvents()
            if let firstEvent = localEvents.first {
                featuredEvent = firstEvent
            }
            events = try eventService.events()
        } catch {
            print("Error loading events: \(error)")
        }
    }

    func buyTickets() {
        print("\(#function)")
    }
}
