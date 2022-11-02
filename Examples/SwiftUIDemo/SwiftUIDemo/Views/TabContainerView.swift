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
                .tabItem {
                    Text("Events")
                    Image(systemName: "calendar")
                 }
                .tag(Tab.events)

            LoginView(viewModel: .init(onComplete: {
                self.selectedTab = .events
            }))
                .tabItem {
                    Text("Login")
                    Image(systemName: "lock")
                 }
                .tag(Tab.login)

            ProfileView(viewModel: .init())
                .tabItem {
                    Text("Profile")
                    Image(systemName: "person.fill")
                 }
                .tag(Tab.profile)

            SettingsView(viewModel: .init())
                .tabItem {
                    Text("Settings")
                    Image(systemName: "gearshape.fill")
                 }
                .tag(Tab.settings)
        }
    }
}

struct TabContainerView_Previews: PreviewProvider {
    static var previews: some View {
        TabContainerView(
            eventService: .mock)
    }
}
