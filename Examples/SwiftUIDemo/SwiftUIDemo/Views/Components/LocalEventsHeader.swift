//
//  LocalEventsHeader.swift
//  SwiftUIDemo
//
//  Created by Mathew Gacy on 10/25/22.
//  Copyright © 2022 Lytics. All rights reserved.
//

import SwiftUI

struct LocalEventsHeader: View {
    let action: () -> Void

    init(action: @escaping () -> Void = {}) {
        self.action = action
    }

    var body: some View {
        HStack {
            Text("Near you")
                .bold()

            Spacer()

            Button(
                action: action,
                label: {
                    Text("See more")
                })
        }
    }
}

struct LocalEventsHeader_Previews: PreviewProvider {
    static var previews: some View {
        LocalEventsHeader()
    }
}
