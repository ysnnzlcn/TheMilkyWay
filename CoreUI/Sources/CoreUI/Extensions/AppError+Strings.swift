//
//  AppError+Strings.swift
//  CoreUI
//

import CoreAssets
import CoreBase

/// What an error shows. The only place error text is chosen; it comes from the `errors` String Catalog.
public struct ErrorCopy: Equatable, Sendable {
    /// Full-screen message (`HeaderMessage`).
    public let title: String
    public let description: String
    public let buttonTitle: String
    public let systemImage: SystemImage
    /// Error toast.
    public let toastText: String
}

public extension AppError {

    var copy: ErrorCopy {
        switch self {
        case .api(.offline):
            ErrorCopy(
                title: L10n.Errors.offlineTitle,
                description: L10n.Errors.offlineDescription,
                buttonTitle: L10n.Errors.retry,
                systemImage: .wifiSlash,
                toastText: L10n.Errors.offlineToast
            )
        case .api(.timeout):
            ErrorCopy(
                title: L10n.Errors.genericTitle,
                description: L10n.Errors.timeoutDescription,
                buttonTitle: L10n.Errors.retry,
                systemImage: .exclamationmarkTriangle,
                toastText: L10n.Errors.genericToast
            )
        case .api, .unexpected:
            ErrorCopy(
                title: L10n.Errors.genericTitle,
                description: L10n.Errors.genericDescription,
                buttonTitle: L10n.Errors.retry,
                systemImage: .exclamationmarkTriangle,
                toastText: L10n.Errors.genericToast
            )
        }
    }

    var isOffline: Bool { self == .api(.offline) }

    /// The UIKit screens' alert text, until they move to SwiftUI.
    var message: String { copy.description }
}
