//
//  File.swift
//
//  Created by Mathew Gacy on 10/19/22.
//

import Foundation

struct File {
    let directory: URL
    let name: String

    var url: URL {
        directory.appendingPathComponent(name)
    }

    var path: String {
        url.path
    }

    init(directory: URL, name: String) {
        self.directory = directory
        self.name = name
    }
}
