//
//  SettingsView.swift
//  SwiftUIDemo
//
//  Created by Mathew Gacy on 10/24/22.
//  Copyright © 2022 Lytics. All rights reserved.
//

import LyticsUI
import SwiftUI

struct SettingsView: View {
    @StateObject var viewModel: SettingsViewModel

    var body: some View {
        List {
            Button(
                action: {
                    viewModel.reset()
                },
                label: {
                    Text("Reset Demo App")
                })

            Button(
                action: {
                    viewModel.dispatch()
                },
                label: {
                    Text("Dispatch Events")
                })
        }
        .trackScreen(
            name: "Settings")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(viewModel: .init())
    }
}
