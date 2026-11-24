//
//  AppError.swift
//  Core
//

import Foundation

/// Every failure in the app. CoreUI turns it into text.
public enum AppError: Error, Equatable, Sendable {

    case api(Kind)
    /// A dead end (a bug). The description is for debugging only.
    case unexpected(String)

    public enum Kind: String, Sendable {
        case offline
        case timeout
        case cancelled
        case server
        case decoding
    }
}
