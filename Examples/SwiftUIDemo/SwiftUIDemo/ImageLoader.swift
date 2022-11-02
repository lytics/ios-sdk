//
//  ImageLoader.swift
//  SwiftUIDemo
//
//  Created by Mathew Gacy on 10/25/22.
//  Copyright © 2022 Lytics. All rights reserved.
//

import Foundation
import SwiftUI

// MARK: - Environment

struct ImageLoaderKey: EnvironmentKey {
    static let defaultValue = ImageLoader.mock
}

extension EnvironmentValues {
    var imageLoader: ImageLoader {
        get { self[ImageLoaderKey.self] }
        set { self[ImageLoaderKey.self ] = newValue}
    }
}

// MARK: - Loader

struct ImageLoader {
    var fetch: (URL) async throws -> Image
}

extension ImageLoader {
    static var mock: Self {
        .init(
            fetch: { url in
                switch url.lastPathComponent {
                case "3":
                    return Image.aliciaKeys
                case "4":
                    return Image.postMalone
                case "5":
                    return Image.dojaCat
                default:
                    return Image.maroon5
                }
            }
        )
    }
}
