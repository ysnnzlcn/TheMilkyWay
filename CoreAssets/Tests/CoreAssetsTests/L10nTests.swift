//
//  L10nTests.swift
//  CoreAssetsTests
//

import CoreAssets
import Testing

/// Keys are checked when compiling; this checks the bundle really serves the text (a missing value returns the key).
struct L10nTests {

    @Test(arguments: [
        ("generic.description", L10n.Errors.genericDescription),
        ("generic.title", L10n.Errors.genericTitle),
        ("generic.toast", L10n.Errors.genericToast),
        ("offline.description", L10n.Errors.offlineDescription),
        ("offline.title", L10n.Errors.offlineTitle),
        ("offline.toast", L10n.Errors.offlineToast),
        ("retry", L10n.Errors.retry),
        ("timeout.description", L10n.Errors.timeoutDescription),
    ])
    func errorStringsResolve(key: String, value: String) {
        #expect(value != key)
        #expect(!value.isEmpty)
    }

    @Test(arguments: [
        ("noResults.description", L10n.Explore.noResultsDescription),
        ("noResults.title", L10n.Explore.noResultsTitle),
        ("searchPrompt", L10n.Explore.searchPrompt),
        ("title", L10n.Explore.title),
    ])
    func exploreStringsResolve(key: String, value: String) {
        #expect(value != key)
        #expect(!value.isEmpty)
    }

    @Test(arguments: [
        ("tabs.explore", L10n.Core.tabsExplore),
        ("tabs.favorites", L10n.Core.tabsFavorites),
        ("favoriteButton.add", L10n.Coreui.favoriteButtonAdd),
        ("favoriteButton.remove", L10n.Coreui.favoriteButtonRemove),
        ("empty.description", L10n.Favorites.emptyDescription),
        ("empty.title", L10n.Favorites.emptyTitle),
        ("title", L10n.Favorites.title),
        ("favoriteAdded", L10n.ImageDetails.favoriteAdded),
        ("favoriteRemoved", L10n.ImageDetails.favoriteRemoved),
    ])
    func featureStringsResolve(key: String, value: String) {
        #expect(value != key)
        #expect(!value.isEmpty)
    }

    @Test func formatsInsertTheirArgument() {
        #expect(L10n.Coreui.toastErrorAnnouncement("Offline") == "Error, Offline")
    }
}
