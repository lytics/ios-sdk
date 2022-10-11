//
//  PathProvider.swift
//
//  Created by Mathew Gacy on 10/1/22.
//

import Foundation

/// A type that provides the path of a resource.
protocol PathProvider {

    /// The resource path.
    var path: String { get }
}
