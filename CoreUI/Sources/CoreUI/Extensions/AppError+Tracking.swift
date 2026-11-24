//
//  AppError+Tracking.swift
//  CoreUI
//

import CoreBase

public extension AppError {

    /// The stable name `error_shown` reports: never rename one. No text and no personal data.
    var trackingName: String {
        switch self {
        case let .network(kind): "network.\(kind.rawValue)"
        case .storage: "storage"
        case .unexpected: "unexpected"
        }
    }
}
