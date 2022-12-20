//
//  EventDetailView.swift
//  SwiftUIDemo
//
//  Created by Mathew Gacy on 10/24/22.
//  Copyright © 2022 Lytics. All rights reserved.
//

import LyticsUI
import SwiftUI

struct EventDetailView: View {
    @StateObject var viewModel: EventDetailViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            RemoteImage(url: viewModel.imageURL, contentMode: .fit)

            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.title)
                        .font(.headline)

                    Text(viewModel.subtitle)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("DETAILS")

                    Text(viewModel.details)
                }

                Button(
                    action: {
                        viewModel.buyTickets()
                    },
                    label: {
                        Text("Buy Tickets")
                    })
                .buttonStyle(.secondary())
            }
            .padding(.horizontal)

            Spacer()
        }
        .onAppear {
            viewModel.onAppear()
        }
        .trackScreen(
            name: "Event_Detail",
            properties: DemoDetailScreenEvent(
                artistName: viewModel.title))
    }
}

struct EventDetailView_Previews: PreviewProvider {
    static var previews: some View {
        EventDetailView(viewModel: .init(
            eventService: .mock,
            event: .mock))
    }
}
