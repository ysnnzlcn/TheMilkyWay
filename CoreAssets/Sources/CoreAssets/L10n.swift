//
//  L10n.swift
//  CoreAssets
//

import Foundation

/// Every user-facing string, from the String Catalogs in `Resources/Strings`, one table per owner: `coreui` for
/// components, `errors` for every error text (read only by CoreUI `AppError+Strings`), one per feature.
/// Wraps the symbols Xcode generates for each catalog (internal to this module), so a wrong key fails to compile.
public enum L10n {

    public enum Coreui {

        /// "Error, %@"
        public static func toastErrorAnnouncement(_ text: String) -> String {
            String(localized: .Coreui.toastErrorAnnouncement(text))
        }
    }

    public enum Explore {

        public static var noResultsDescription: String { String(localized: .Explore.noResultsDescription) }
        public static var noResultsTitle: String { String(localized: .Explore.noResultsTitle) }
        public static var searchPrompt: String { String(localized: .Explore.searchPrompt) }
        public static var title: String { String(localized: .Explore.title) }
    }

    public enum Errors {

        public static var genericDescription: String { String(localized: .Errors.genericDescription) }
        public static var genericTitle: String { String(localized: .Errors.genericTitle) }
        public static var genericToast: String { String(localized: .Errors.genericToast) }
        public static var offlineDescription: String { String(localized: .Errors.offlineDescription) }
        public static var offlineTitle: String { String(localized: .Errors.offlineTitle) }
        public static var offlineToast: String { String(localized: .Errors.offlineToast) }
        public static var retry: String { String(localized: .Errors.retry) }
        public static var timeoutDescription: String { String(localized: .Errors.timeoutDescription) }
    }
}
