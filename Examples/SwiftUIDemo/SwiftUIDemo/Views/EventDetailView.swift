//
//  EventDetailView.swift
//  SwiftUIDemo
//
//  Created by Mathew Gacy on 10/24/22.
//  Copyright © 2022 Lytics. All rights reserved.
//

import SwiftUI

struct EventDetailView: View {
    @StateObject var viewModel: EventDetailViewModel

    var body: some View {
        Text("Event Detail")
    }
}

struct EventDetailView_Previews: PreviewProvider {
    static var previews: some View {
        EventDetailView(viewModel: .init())
    }
}
