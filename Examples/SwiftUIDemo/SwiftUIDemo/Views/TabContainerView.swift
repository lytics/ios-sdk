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

    @State private var selectedTab: Tab = .events

    public var body: some View {
        TabView(selection: $selectedTab) {
            EventsView()
                .tag(0)
                .tabItem {
                    Text("Events")
                    Image(systemName: "calendar")
                 }

            LoginView()
                .tag(1)
                .tabItem {
                    Text("Login")
                    Image(systemName: "lock")
                 }

            ProfileView()
                .tag(2)
                .tabItem {
                    Text("Profile")
                    Image(systemName: "person.fill")
                 }

            SettingsView()
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
        )
    }
}
