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

    @Test func formatsInsertTheirArgument() {
        #expect(L10n.Coreui.toastErrorAnnouncement("Offline") == "Error, Offline")
    }
}
