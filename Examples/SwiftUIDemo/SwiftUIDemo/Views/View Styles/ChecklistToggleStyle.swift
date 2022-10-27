//
//  ChecklistToggleStyle.swift
//  SwiftUIDemo
//
//  Created by Mathew Gacy on 10/25/22.
//  Copyright © 2022 Lytics. All rights reserved.
//

import SwiftUI

struct ChecklistToggleStyle: ToggleStyle {
    let color: Color

    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            HStack {
                Image(systemName: configuration.isOn
                        ? "checkmark.square"
                        : "square")
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(color)

                configuration.label
            }
        }
        .tint(.primary)
        .buttonStyle(.borderless)
    }
}

extension ToggleStyle where Self == ChecklistToggleStyle {
    static func checklist(color: Color = .black) -> ChecklistToggleStyle {
        ChecklistToggleStyle(color: color)
    }
}

struct ChecklistToggleStyle_Previews: PreviewProvider {
    static var previews: some View {
        Toggle(isOn: .constant(true)) {
            Text("I've read and agree with the **Terms and Conditions** and the **Privacy Policy**.")
                .multilineTextAlignment(.leading)
        }
        .toggleStyle(.checklist())
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
