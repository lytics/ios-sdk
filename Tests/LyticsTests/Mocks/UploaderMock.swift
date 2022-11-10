//
//  UploaderMock.swift
//
//  Created by Mathew Gacy on 11/9/22.
//

@testable import Lytics
import Foundation

actor UploaderMock<R: Codable>: Uploading {
    var onUpload: ([Request<R>]) -> Void
    var onStore: () -> Void

    init(
        onUpload: @escaping ([Request<R>]) -> Void = { _ in },
        onStore: @escaping () -> Void = {}
    ) {
        self.onUpload = onUpload
        self.onStore = onStore
    }

    func upload<T: Codable>(_ requests: [Request<T>]) {
       let requests = requests as! [Request<R>]
       onUpload(requests)
    }

    func storeRequests() {
        onStore()
    }
}
