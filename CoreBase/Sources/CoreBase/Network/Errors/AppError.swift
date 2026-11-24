//
//  AppError.swift
//  CoreBase
//

import Foundation

/// Every failure in the app, grouped by where it happened. CoreUI turns it into text.
public enum AppError: Error, Equatable, Sendable {

    /// A request to a server failed.
    case network(NetworkKind)
    /// Reading or saving data on the phone failed.
    case storage
    /// A dead end (a bug). The description is for debugging only.
    case unexpected(String)

    public enum NetworkKind: String, Sendable {
        case offline
        case timeout
        /// The request was cancelled, e.g. a newer search replaced it. Features don't see it: the effect that asked
        /// was cancelled too, so its answer is dropped.
        case cancelled
        case server
        case decoding
    }
}
