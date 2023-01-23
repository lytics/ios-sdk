//
//  Uploader.swift
//
//  Created by Mathew Gacy on 10/16/22.
//

import Foundation

/// Uploads requests to the Lytics API.
actor Uploader: Uploading {

    /// A wrapper for an in-progress request.
    final class PendingRequest<R: Codable>: Codable, Equatable, RequestWrapping {

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

        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<CodingKeys> = try decoder.container(
                keyedBy: CodingKeys.self)

            self.id = try container.decode(UUID.self, forKey: .id)
            self.request = try container.decode(Request<R>.self, forKey: .request)
            self.retryCount = 0
            self.uploadTask = nil
        }

        func encode(to encoder: Encoder) throws {
            var container: KeyedEncodingContainer<CodingKeys> = encoder.container(
                keyedBy: CodingKeys.self)

            try container.encode(id, forKey: .id)
            try container.encode(request, forKey: .request)
        }

        func cancel() {
            uploadTask?.cancel()
            uploadTask = nil
        }

        static func == (lhs: PendingRequest<R>, rhs: PendingRequest<R>) -> Bool {
            lhs.id == rhs.id
                && lhs.request == rhs.request
                && lhs.retryCount == rhs.retryCount
                && lhs.uploadTask == rhs.uploadTask
        }

        private enum CodingKeys: CodingKey {
            case id
            case request
        }
    }

    private let logger: LyticsLogger
    private let decoder: JSONDecoder
    private let requestPerformer: RequestPerforming
    private let errorHandler: RequestFailureHandler
    private let cache: RequestCaching?
    private var pendingRequests: [UUID: any RequestWrapping]

    /// A Boolean value that indicates whether any requests passed to `upload(_:)` should be upload or stored immediately.
    private(set) var shouldSend: Bool

    /// The number of requests waiting to be uploaded.
    var pendingRequestCount: Int {
        pendingRequests.count
    }

    init(
        logger: LyticsLogger,
        decoder: JSONDecoder = .init(),
        requestPerformer: RequestPerforming,
        errorHandler: RequestFailureHandler,
        cache: RequestCaching?,
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
            let wrapped: [any RequestWrapping] = requests.map { PendingRequest(request: $0) }
            do {
                try cache?.cache(wrapped)
            } catch {
                logger.error("Unable to cache \(requests): \(error)")
            }

            return
        }

        for request in requests {
            var wrapper = PendingRequest(request: request)
            add(&wrapper)
        }
    }

    /// Stores pending requests and cancels their upload tasks.
    func storeRequests() {
        shouldSend = false
        pendingRequests.forEach { $0.value.cancel() }

        for (id, wrapper) in pendingRequests {
            pendingRequests[id] = nil
            openAndCache(wrapper)
        }
    }

    /// Loads stored requests and send them.
    func loadRequests() throws {
        guard let wrapped = try cache?.load() else {
            return
        }

        logger.debug("Retrying stored requests: \(wrapped)")

        for idx in wrapped.indices {
            var wrapper = wrapped[idx]
            add(&wrapper)
        }

        try cache?.deleteAll()
    }
}

private extension Uploader {

    /// Adds a request wrapper to `pendingRequests` and creates its upload task.
    /// - Parameter wrapper: The instance wrapping the request to upload.
    func add<T: RequestWrapping>(_ wrapper: inout T) {
        pendingRequests[wrapper.id] = wrapper
        wrapper.uploadTask = makeUploadTask(id: wrapper.id, request: wrapper.request)
    }

    /// Removes a wrapped request from `pendingRequests` and cancels its upload task.
    /// - Parameter id: The unique value identifying the wrapper of the request to be removed.
    func remove(id: UUID) {
        pendingRequests[id]?.cancel()
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
                .decode(with: decoder)

            logger.debug("\(response)")

            remove(id: id)

            do {
                try loadRequests()
            } catch {
                logger.error("Error while trying to restart stored requests: \(error)")
            }
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
            try cache?.cache([wrapper])
        } catch {
            logger.error("Unable to cache \(wrapper): \(error)")
        }
    }

    /// Returns a task to send a request.
    /// - Parameters:
    ///   - id: The unique identifier of the request's wrapper.
    ///   - request: The request to send.
    func makeUploadTask<T: Codable>(id: UUID, request: Request<T>) -> Task<Void, Never> {
        Task.detached(priority: .utility) { [weak self] in
            await self?.send(request: request, id: id)
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
        case let .discard(reason):
            logger.info("Unable to recover from \(error) uploading request \(wrapper.id): \(reason)")
            remove(id: id)

        case let .retry(delay):
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
            logger.debug("Storing request \(wrapper.id)")
            remove(id: id)
            openAndCache(wrapper)
        }
    }
}

extension Uploader {
    static func live(
        logger: LyticsLogger,
        cache: RequestCaching?,
        maxRetryCount: Int
    ) -> Uploader {
        .init(
            logger: logger,
            requestPerformer: URLSession.live,
            errorHandler: .live(maxRetryCount: maxRetryCount),
            cache: cache
        )
    }
}
