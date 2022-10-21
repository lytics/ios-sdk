//
//  Uploader.swift
//
//  Created by Mathew Gacy on 10/16/22.
//

import Foundation

/// Uploads requests to the Lytics API.
actor Uploader: Uploading {

    /// A wrapper for an in-progress request.
    final class PendingRequest<R: Codable>: RequestWrapping {

        /// A unique value identifying the wrapped request.
        let id: UUID

        /// The wrapped request.
        let request: Request<R>

        /// A count of attempts to upload the wrapped requeust.
        var retryCount: Int = 0

        /// The task to upload the wrapped request.
        var uploadTask: Task<Void, Never>?

        init(
            id: UUID = .init(),
            request: Request<R>,
            retryCount: Int = 0,
            uploadTask: Task<Void, Never>? = nil
        ) {
            self.id = id
            self.request = request
            self.retryCount = retryCount
            self.uploadTask = uploadTask
        }
    }

    private let logger: LyticsLogger
    private let decoder: JSONDecoder
    private let requestPerformer: RequestPerforming
    private let errorHandler: RequestFailureHandler
    private let cache: RequestCaching
    private var pendingRequests: [UUID: any RequestWrapping]

    /// A Boolean value that indicates whether any requests passed to `upload(_:)` should be upload or stored immediately.
    var shouldSend: Bool

    /// The number of requests waiting to be uploaded.
    var pendingRequestCount: Int {
        pendingRequests.count
    }

    init(
        logger: LyticsLogger,
        decoder: JSONDecoder = .init(),
        requestPerformer: RequestPerforming,
        errorHandler: RequestFailureHandler,
        cache: RequestCaching,
        shouldSend: Bool = true
    ) {
        self.logger = logger
        self.decoder = decoder
        self.requestPerformer = requestPerformer
        self.errorHandler = errorHandler
        self.cache = cache
        self.pendingRequests = [:]
        self.shouldSend = shouldSend
    }

    /// Uploads requests to the Lytics API.
    /// - Parameter requests: The requests to upload.
    func upload<T: Codable>(_ requests: [Request<T>]) {
        guard shouldSend else {
            for request in requests {
                do {
                    try cache.cache(request)
                } catch {
                    logger.error("Unable to cache \(request): \(error)")
                }
            }

            return
        }

        for request in requests {
            let id = UUID()
            let wrapper = PendingRequest(id: id, request: request)
            pendingRequests[id] = wrapper

            wrapper.uploadTask = Task.detached(priority: .utility) { [weak self] in
                await self?.send(request: request, id: id)
            }
        }
    }

    /// Stores pending requests and cancels their upload tasks.
    func storeRequests() {
        shouldSend = false
        pendingRequests.forEach { $0.value.uploadTask?.cancel() }

        for (id, wrapper) in pendingRequests {
            pendingRequests[id] = nil
            openAndCache(wrapper)
        }
    }
}

private extension Uploader {

    /// Removes a wrapped request from ``requests`` and cancels its task.
    /// - Parameter id: The unique value identifying the wrapper of the request to be removed.
    func remove(id: UUID) {
        pendingRequests[id]?.uploadTask?.cancel()
        pendingRequests[id] = nil
    }

    /// Sends a request to the Lytics API and handle any errors.
    /// - Parameters:
    ///   - request: The request the send.
    ///   - id: The unique value identifying the request's wrapper.
    func send<R: Codable>(request: Request<R>, id: UUID) async {
        do {
            let response = try await requestPerformer
                .perform(request)
                .validate()
                .decode()

            logger.debug("\(response)")

            remove(id: id)
        } catch {
            handleError(error, id: id)
        }
    }
}

private extension Uploader {

    // The following generic methods are used to open an existential element of ``requests`` and access its underlying request.

    /// Sends a request wrapper's request.
    /// - Parameter wrapper: The instance wrapping the request to send.
    func openAndSend<R: RequestWrapping>(_ wrapper: R) async {
        await send(request: wrapper.request, id: wrapper.id)
    }

    /// Caches a request wrapper's request.
    /// - Parameter wrapper: The instance wrapping the request to cache.
    func openAndCache<T: RequestWrapping>(_ wrapper: T) {
        do {
            try cache.cache(wrapper.request)
        } catch {
            logger.error("Unable to cache \(wrapper): \(error)")
        }
    }

    /// Handles a failure to send a request by retrying it, storing it, or giving based on the specific error encountered.
    /// - Parameters:
    ///   - error: The error the handle.
    ///   - id: The unique value identifying the wrapper of the request to which the error is associated.
    func handleError(_ error: Error, id: UUID) {
        logger.error("Request error for \(id): \(error.localizedDescription)")
        guard var wrapper = pendingRequests[id] else {
            logger.debug("Unable to find request \(id)")
            return
        }

        switch errorHandler.strategy(for: error, retryCount: wrapper.retryCount) {
        case .discard(let reason):
            logger.info("Unable to recover from \(error) uploading request \(wrapper.id): \(reason)")
            remove(id: id)

        case .retry(let delay):
            logger.debug("Retrying request \(wrapper.id) in \(delay)")
            wrapper.retryCount += 1
            wrapper.uploadTask = Task.delayed(byTimeInterval: delay) { [weak self] in
                guard let wrapper = await self?.pendingRequests[id] else {
                    self?.logger.debug("Unable to find request \(id)")
                    return
                }

                await self?.openAndSend(wrapper)
            }

        case .store:
            remove(id: id)
            openAndCache(wrapper)
        }
    }
}

extension Uploader {
    static func live(
        logger: LyticsLogger,
        cache: RequestCaching,
        maxRetryCount: Int
    ) -> Uploader {
        .init(
            logger: logger,
            requestPerformer: URLSession.live,
            errorHandler: .live(maxRetryCount: maxRetryCount),
            cache: cache)
    }
}
