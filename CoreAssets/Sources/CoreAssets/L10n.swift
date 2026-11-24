//
//  L10n.swift
//  CoreAssets
//

import Foundation

/// Every user-facing string, from the String Catalogs in `Resources/Strings`, one table per owner: `coreui` for
/// components, `errors` for every error text (read only by CoreUI `AppError+Strings`), one per feature.
/// Wraps the symbols Xcode generates for each catalog (internal to this module), so a wrong key fails to compile.
public enum L10n {

    public enum Core {

        public static var tabsExplore: String { String(localized: .Core.tabsExplore) }
        public static var tabsFavorites: String { String(localized: .Core.tabsFavorites) }
    }

    public enum Coreui {

        public static var favoriteButtonAdd: String { String(localized: .Coreui.favoriteButtonAdd) }
        public static var favoriteButtonRemove: String { String(localized: .Coreui.favoriteButtonRemove) }

        /// "Error, %@"
        public static func toastErrorAnnouncement(_ text: String) -> String {
            String(localized: .Coreui.toastErrorAnnouncement(text))
        }
    }

    public enum Favorites {

        public static var emptyDescription: String { String(localized: .Favorites.emptyDescription) }
        public static var emptyTitle: String { String(localized: .Favorites.emptyTitle) }
        public static var title: String { String(localized: .Favorites.title) }
    }

    public enum ImageDetails {

        public static var favoriteAdded: String { String(localized: .ImageDetails.favoriteAdded) }
        public static var favoriteRemoved: String { String(localized: .ImageDetails.favoriteRemoved) }
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
