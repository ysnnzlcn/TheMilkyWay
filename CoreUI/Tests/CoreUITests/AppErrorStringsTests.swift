//
//  AppErrorStringsTests.swift
//  CoreUITests
//

import CoreAssets
import CoreBase
import CoreUI
import Testing

struct AppErrorStringsTests {

    @Test func offlineHasItsOwnCopyAndToast() {
        let copy = AppError.network(.offline).copy

        #expect(copy.title == L10n.Errors.offlineTitle)
        #expect(copy.toastText == L10n.Errors.offlineToast)
        #expect(copy.systemImage == .wifiSlash)
        #expect(copy.toastStatus == .noConnection)
    }

    @Test func timeoutSaysTheConnectionIsSlow() {
        let copy = AppError.network(.timeout).copy

        #expect(copy.description == L10n.Errors.timeoutDescription)
        #expect(copy.toastStatus == .error)
    }

    @Test(arguments: [
        AppError.network(.server), .network(.decoding), .network(.cancelled), .storage, .unexpected("bug"),
    ])
    func otherErrorsShowGenericCopy(error: AppError) {
        let copy = error.copy

        #expect(copy.title == L10n.Errors.genericTitle)
        #expect(copy.description == L10n.Errors.genericDescription)
        #expect(copy.systemImage == .exclamationmarkTriangle)
        #expect(copy.toastStatus == .error)
    }
}
