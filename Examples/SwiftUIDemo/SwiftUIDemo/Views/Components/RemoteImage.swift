//
//  RemoteImage.swift
//  SwiftUIDemo
//
//  Created by Mathew Gacy on 10/26/22.
//  Copyright © 2022 Lytics. All rights reserved.
//

import SwiftUI

struct RemoteImage: View {
    private let url: URL
    private let contentMode: ContentMode
    @State private var image: Image?

    @Environment(\.imageLoader) private var imageLoader

    init(url: URL, contentMode: ContentMode = .fill) {
        self.url = url
        self.contentMode = contentMode
    }

    var body: some View {
        Group {
            if let image = image {
                image
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.gray)
                    .padding()
            }
        }
        .task {
            await loadImage(at: url)
        }
    }

    func loadImage(at url: URL) async {
        do {
            image = try await imageLoader.fetch(url)
        } catch {
            print(error)
        }
    }
}
