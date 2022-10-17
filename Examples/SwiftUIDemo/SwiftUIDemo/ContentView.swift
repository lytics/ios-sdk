//
//  ContentView.swift
//  SwiftUIDemo
//
//  Created by Mathew Gacy on 10/1/22.
//  
//

import Lytics
import SwiftUI

struct ContentView: View {
    @State var identity: DemoIdentity

    var body: some View {
        VStack {
            TextField("User ID", text: $identity.userID)

            TextField("Email", text: $identity.email)

            Button(
                action: {
                    sendEvent()
                },
                label: {
                    Text("Track")
                })
        }
        .padding()
    }

    func sendEvent() {
        Lytics.shared.track(stream: "Demo", identifiers: identity, properties: .never)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(identity: DemoIdentity(userID: "Jane Doe", email: "j@mail.com"))
    }
}
