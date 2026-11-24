//
//  FavoritesServiceImpl.swift
//  CoreLogicImpl
//

import CoreBase
import CoreLogic
import Foundation
import SwiftData

/// Favorites in SwiftData. A plain actor that owns its store: every read and write runs on this actor, one at a time
/// and off the main thread, and records are mapped to `NASAImageDTO` before they leave it. Each `updates()`
/// subscriber gets the list again after every change.
///
/// Not a `@ModelActor`: on iOS 27 its default executor ran the work on the main thread (checked with a probe test),
/// while a plain actor runs on Swift's shared thread pool.
actor FavoritesServiceImpl: FavoritesService {

    private let makeContainer: @Sendable () -> ModelContainer
    private let now: @Sendable () -> Date
    /// Made on first use, on this actor: the store opens off the main thread, not at launch, and the context
    /// belongs to the actor that uses it.
    private var context: ModelContext?
    /// The last list read, so a new subscriber doesn't read the store again.
    private var latest: Result<[NASAImageDTO], AppError>?
    private var continuations: [UUID: AsyncStream<Result<[NASAImageDTO], AppError>>.Continuation] = [:]

    /// How many `updates()` streams are open (for tests).
    var subscriberCount: Int { continuations.count }

    init(makeContainer: @escaping @Sendable () -> ModelContainer, now: @escaping @Sendable () -> Date = { .now }) {
        self.makeContainer = makeContainer
        self.now = now
    }

    func updates() -> AsyncStream<Result<[NASAImageDTO], AppError>> {
        // A slow reader only needs the latest list.
        let (stream, continuation) = AsyncStream.makeStream(
            of: Result<[NASAImageDTO], AppError>.self,
            bufferingPolicy: .bufferingNewest(1)
        )
        let id = UUID()
        continuations[id] = continuation
        continuation.onTermination = { [weak self] _ in
            Task { await self?.removeContinuation(id) }
        }
        continuation.yield(latestList())
        return stream
    }

    func add(_ image: NASAImageDTO) -> Result<Void, AppError> {
        let context = modelContext()
        do {
            // Saving again replaces the stored copy and moves it to the top.
            try context.fetch(Self.descriptor(id: image.id)).forEach(context.delete)
            context.insert(FavoriteImageRecord(image: image, savedAt: now()))
            try context.save()
        } catch {
            context.rollback()
            return .failure(Self.storageError("add", error))
        }
        publish()
        return .success(())
    }

    func remove(id: String) -> Result<Void, AppError> {
        let context = modelContext()
        do {
            try context.fetch(Self.descriptor(id: id)).forEach(context.delete)
            try context.save()
        } catch {
            context.rollback()
            return .failure(Self.storageError("remove", error))
        }
        publish()
        return .success(())
    }

    // MARK: Private

    private func modelContext() -> ModelContext {
        if let context { return context }
        let context = ModelContext(makeContainer())
        self.context = context
        return context
    }

    private func latestList() -> Result<[NASAImageDTO], AppError> {
        if let latest { return latest }
        let list = fetchAll()
        latest = list
        return list
    }

    private func fetchAll() -> Result<[NASAImageDTO], AppError> {
        let descriptor = FetchDescriptor<FavoriteImageRecord>(sortBy: [SortDescriptor(\.savedAt, order: .reverse)])
        do {
            return .success(try modelContext().fetch(descriptor).map(\.image))
        } catch {
            return .failure(Self.storageError("fetch", error))
        }
    }

    /// Reads the list once after a change and sends it to every subscriber.
    private func publish() {
        let list = fetchAll()
        latest = list
        continuations.values.forEach { $0.yield(list) }
    }

    private func removeContinuation(_ id: UUID) {
        continuations[id] = nil
    }

    private static func descriptor(id: String) -> FetchDescriptor<FavoriteImageRecord> {
        FetchDescriptor(predicate: #Predicate { $0.id == id })
    }

    private static func storageError(_ operation: String, _ error: any Error) -> AppError {
        Log.error("Favorites \(operation) failed: \(type(of: error))", .favorites)
        return .storage
    }
}
