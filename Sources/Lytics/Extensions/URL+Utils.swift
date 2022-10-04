//
//  URL+Utils.swift
//
//  Created by Mathew Gacy on 10/1/22.
//

import Foundation

extension URL {
    func appending<T: PathProvider>(_ provider: T) -> URL {
        appendingPathComponent(provider.path)
    }
}
