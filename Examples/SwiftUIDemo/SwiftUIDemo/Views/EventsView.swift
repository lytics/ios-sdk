//
//  EventsView.swift
//  SwiftUIDemo
//
//  Created by Mathew Gacy on 10/24/22.
//  Copyright © 2022 Lytics. All rights reserved.
//

import SwiftUI

struct EventsView: View {
    @StateObject var viewModel: EventsViewModel

    var body: some View {
        NavigationStack {
            VStack {
                if let featuredEvent = viewModel.featuredEvent {
                    VStack {
                        LocalEventsHeader(
                            action: { print("See More ...") })

                        EventCard(
                            title: featuredEvent.artist.name,
                            subtitle: featuredEvent.location,
                            imageURL: featuredEvent.imageURL,
                            action: {
                                viewModel.buyTickets()
                            })
                    }
                }

                HStack {
                    Text("Popular")
                        .bold()

                    Spacer()
                }

                ForEach(viewModel.events) { event in
                    NavigationLink(value: event) {
                        EventRow(
                            title: event.artist.name,
                            subtitle: event.location,
                            imageURL: event.imageURL)
                    }
                }
                .navigationDestination(for: Event.self) { event in
                    EventDetailView(viewModel: .init(eventService: .mock, event: event))
                }

                Spacer()
            }
            .padding()
            .onAppear {
                viewModel.fetchEvents()
            }
        }
    }
}

struct EventsView_Previews: PreviewProvider {
    static var previews: some View {
        EventsView(
            viewModel: .init(
                eventService: .mock,
                featuredEvent: .mock,
                events: [.mock]
            ))
    }
}
