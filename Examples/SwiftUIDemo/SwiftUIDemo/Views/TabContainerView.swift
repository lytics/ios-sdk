//
//  TabContainerView.swift
//  SwiftUIDemo
//
//  Created by Mathew Gacy on 10/24/22.
//  Copyright © 2022 Lytics. All rights reserved.
//

import SwiftUI

struct TabContainerView: View {
    enum Tab: Hashable {
        case events
        case login
        case profile
        case settings
    }

    let eventService: EventService
    @State private var selectedTab: Tab = .events

    var body: some View {
        TabView(selection: $selectedTab) {
            EventsView(viewModel: .init(eventService: eventService))
                .tag(0)
                .tabItem {
                    Text("Events")
                    Image(systemName: "calendar")
                 }

            LoginView(viewModel: .init())
                .tag(1)
                .tabItem {
                    Text("Login")
                    Image(systemName: "lock")
                 }

            ProfileView(viewModel: .init())
                .tag(2)
                .tabItem {
                    Text("Profile")
                    Image(systemName: "person.fill")
                 }

            SettingsView(viewModel: .init())
                .tag(3)
                .tabItem {
                    Text("Settings")
                    Image(systemName: "gearshape.fill")
                 }
        }
    }
}

struct TabContainerView_Previews: PreviewProvider {
    static var previews: some View {
        TabContainerView(
            eventService: .mock)
    }
}
