//
//  SecondaryButtonStyle.swift
//  SwiftUIDemo
//
//  Created by Mathew Gacy on 10/25/22.
//  Copyright © 2022 Lytics. All rights reserved.
//

import SwiftUI

struct SecondaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    let color: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity)
            .foregroundColor(color)
            .padding(15)
            .cornerRadius(5)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(.blue, lineWidth: 1)
            )
            .opacity(configuration.isPressed || !isEnabled ? 0.5 : 1.0)
    }
}

extension ButtonStyle where Self == SecondaryButtonStyle {
    static func secondary(color: Color = .blue) -> SecondaryButtonStyle {
        SecondaryButtonStyle(color: color)
    }
}

struct SecondaryButtonStyle_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            Button(action: {}, label: { Text("Enabled") })
                .buttonStyle(.secondary())
                .padding()
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Enabled")

            Button(action: {}, label: { Text("Disabled") })
                .disabled(true)
                .buttonStyle(.secondary())
                .padding()
                .previewLayout(.sizeThatFits)
                .previewDisplayName("Disabled")
        }
    }
}
