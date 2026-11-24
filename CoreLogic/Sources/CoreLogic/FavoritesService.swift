//
//  FavoritesService.swift
//  CoreLogic
//

import CoreBase

/// The images the person saved, kept on the phone, so their details are there offline too.
public protocol FavoritesService: Sendable {

    /// The saved images, newest first, now and after every change. A failed read sends a failure. Screens follow it
    /// instead of reading once, so a change made on another screen shows everywhere.
    func updates() async -> AsyncStream<Result<[NASAImageDTO], AppError>>

    /// Saves `image`, or moves it to the top if it is already saved.
    func add(_ image: NASAImageDTO) async -> Result<Void, AppError>

    func remove(id: String) async -> Result<Void, AppError>
}

/// The default before the app wires the real service: any use is a bug.
public struct FavoritesServiceUnimplemented: FavoritesService {

    public init() { }

    public func updates() async -> AsyncStream<Result<[NASAImageDTO], AppError>> { fatalError("Not implemented") }
    public func add(_ image: NASAImageDTO) async -> Result<Void, AppError> { fatalError("Not implemented") }
    public func remove(id: String) async -> Result<Void, AppError> { fatalError("Not implemented") }
}
