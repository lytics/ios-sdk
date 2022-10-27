//
//  Bundle+Utils.swift
//  SwiftUIDemo
//
//  Created by Mathew Gacy on 10/25/22.
//  Copyright © 2022 Lytics. All rights reserved.
//

import Foundation

extension Bundle {
    func loadJSON(filename: String) throws -> Data? {
        guard let url = url(forResource: filename, withExtension: "json") else {
            return nil
        }
        return try Data(contentsOf: url)
    }
}
