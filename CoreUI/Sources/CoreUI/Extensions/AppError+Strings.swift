//
//  AppError+Strings.swift
//  CoreUI
//

import CoreAssets
import CoreBase

/// How an error shows. The only place error text and its look are chosen; the text comes from the `errors` String
/// Catalog. A full-screen error's button is always "Try again" (`L10n.Errors.retry`).
public struct ErrorCopy: Equatable, Sendable {
    /// Full-screen message (`HeaderMessage`).
    public let title: String
    public let description: String
    public let systemImage: SystemImage
    /// Error toast.
    public let toastText: String
    public let toastStatus: ToastUIModel.Status
}

public extension AppError {

    var copy: ErrorCopy {
        switch self {
        case .network(.offline):
            ErrorCopy(
                title: L10n.Errors.offlineTitle,
                description: L10n.Errors.offlineDescription,
                systemImage: .wifiSlash,
                toastText: L10n.Errors.offlineToast,
                toastStatus: .noConnection
            )
        case .network(.timeout):
            ErrorCopy(
                title: L10n.Errors.genericTitle,
                description: L10n.Errors.timeoutDescription,
                systemImage: .exclamationmarkTriangle,
                toastText: L10n.Errors.genericToast,
                toastStatus: .error
            )
        case .network, .storage, .unexpected:
            ErrorCopy(
                title: L10n.Errors.genericTitle,
                description: L10n.Errors.genericDescription,
                systemImage: .exclamationmarkTriangle,
                toastText: L10n.Errors.genericToast,
                toastStatus: .error
            )
        }
    }
}
