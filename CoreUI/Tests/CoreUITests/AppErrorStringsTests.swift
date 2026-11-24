//
//  AppErrorStringsTests.swift
//  CoreUITests
//

import CoreAssets
import CoreBase
import CoreUI
import Testing

struct AppErrorStringsTests {

    @Test func offlineHasItsOwnCopy() {
        let copy = AppError.api(.offline).copy

        #expect(copy.title == L10n.Errors.offlineTitle)
        #expect(copy.toastText == L10n.Errors.offlineToast)
        #expect(copy.systemImage == .wifiSlash)
    }

    @Test(arguments: [AppError.api(.server), .api(.decoding), .api(.cancelled), .unexpected("bug")])
    func otherErrorsShowGenericCopy(error: AppError) {
        let copy = error.copy

        #expect(copy.title == L10n.Errors.genericTitle)
        #expect(copy.description == L10n.Errors.genericDescription)
        #expect(copy.systemImage == .exclamationmarkTriangle)
    }

    @Test func everyErrorOffersRetry() {
        #expect(AppError.api(.timeout).copy.buttonTitle == L10n.Errors.retry)
    }
}
