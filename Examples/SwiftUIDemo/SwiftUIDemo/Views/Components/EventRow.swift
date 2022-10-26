//
//  EventRow.swift
//  SwiftUIDemo
//
//  Created by Mathew Gacy on 10/24/22.
//  Copyright © 2022 Lytics. All rights reserved.
//

import SwiftUI

struct EventRow: View {
    let title: String
    let subtitle: String
    let image: Image

    var body: some View {
        HStack(spacing: 16) {
            image
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 69)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .bold()

                Text(subtitle)
            }
            .foregroundColor(.primary)


            Spacer()

            Image(systemName: "chevron.right")
                .padding()
        }
        .background(.background)
        .cornerRadius(16)
    }
}

struct EventRow_Previews: PreviewProvider {
    static var previews: some View {
        EventRow(
            title: Event.mock.artist.name,
            subtitle: Event.mock.location,
            image: .image3)
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
