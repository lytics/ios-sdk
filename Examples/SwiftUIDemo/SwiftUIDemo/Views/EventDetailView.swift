//
//  EventDetailView.swift
//  SwiftUIDemo
//
//  Created by Mathew Gacy on 10/24/22.
//  Copyright © 2022 Lytics. All rights reserved.
//

import SwiftUI

struct EventDetailView: View {
    @StateObject var viewModel: EventDetailViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let image = viewModel.image {
                image
                    .resizable()
                    .scaledToFit()
            }

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
            viewModel.fetchImage()
        }
    }
}

struct EventDetailView_Previews: PreviewProvider {
    static var previews: some View {
        EventDetailView(viewModel: .init(
            eventService: .mock,
            event: .mock))
    }
}
