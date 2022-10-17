//
//  StreamEvent.swift
//
//  Created by Mathew Gacy on 10/6/22.
//

import Foundation

protocol StreamEvent: Encodable {
    var stream: String { get }
}
