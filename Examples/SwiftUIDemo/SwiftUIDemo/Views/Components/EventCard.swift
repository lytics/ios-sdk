//
//  EventCard.swift
//  SwiftUIDemo
//
//  Created by Mathew Gacy on 10/24/22.
//  Copyright © 2022 Lytics. All rights reserved.
//

import SwiftUI

struct EventCard: View {
    let title: String
    let subtitle: String
    let image: Image
    let action: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 120, alignment: .top)
                .clipped()

            VStack(alignment: .leading) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .bold()

                    Text(subtitle)
                }

                Button(
                    action: action,
                    label: {
                        Text("Buy tickets")
                    })
                .buttonStyle(.secondary())
            }
            .padding(16)
        }
        .background(.background)
        .cornerRadius(16)
    }
}

struct EventCard_Previews: PreviewProvider {
    static var previews: some View {
        EventCard(
            title: Event.mock.artist,
            subtitle: Event.mock.location,
            image: .image2,
            action: {})
        .previewLayout(.sizeThatFits)
    }
}