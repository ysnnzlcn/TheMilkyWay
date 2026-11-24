//
//  FavoritesServiceMock.swift
//  CoreLogicMocks
//

import CoreBase
import CoreLogic

/// For tests: favorites in memory, newest first, with every call recorded. Set `failure` to make the next calls fail.
public actor FavoritesServiceMock: FavoritesService {

    public private(set) var favorites: [NASAImageDTO]
    public private(set) var addedIDs: [String] = []
    public private(set) var removedIDs: [String] = []
    public private(set) var failure: AppError?

    private var continuations: [Int: AsyncStream<Result<[NASAImageDTO], AppError>>.Continuation] = [:]
    private var nextContinuationID = 0

    public init(favorites: [NASAImageDTO] = [], failure: AppError? = nil) {
        self.favorites = favorites
        self.failure = failure
    }

    public func setFailure(_ failure: AppError?) {
        self.failure = failure
    }

    public func updates() async -> AsyncStream<Result<[NASAImageDTO], AppError>> {
        let (stream, continuation) = AsyncStream.makeStream(of: Result<[NASAImageDTO], AppError>.self)
        continuation.yield(failure.map { .failure($0) } ?? .success(favorites))
        let id = nextContinuationID
        nextContinuationID += 1
        continuations[id] = continuation
        return stream
    }

    public func add(_ image: NASAImageDTO) async -> Result<Void, AppError> {
        addedIDs.append(image.id)
        if let failure { return .failure(failure) }
        favorites.removeAll { $0.id == image.id }
        favorites.insert(image, at: 0)
        publish()
        return .success(())
    }

    public func remove(id: String) async -> Result<Void, AppError> {
        removedIDs.append(id)
        if let failure { return .failure(failure) }
        favorites.removeAll { $0.id == id }
        publish()
        return .success(())
    }

    /// Ends every `updates()` stream, so a test can wait for its subscribers to finish.
    public func finishUpdates() {
        continuations.values.forEach { $0.finish() }
        continuations = [:]
    }

    private func publish() {
        continuations.values.forEach { $0.yield(.success(favorites)) }
    }
}
