//
//  URL+Utils.swift
//
//  Created by Mathew Gacy on 10/1/22.
//

import Foundation

extension URL {

    /// Returns a URL by appending the specified path to self.
    /// - Parameter provider: The instance providing the path to append.
    func appending<T: PathProvider>(_ provider: T) -> URL {
        appendingPathComponent(provider.path)
    }
}
