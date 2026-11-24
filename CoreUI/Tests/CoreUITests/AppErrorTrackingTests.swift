//
//  AppErrorTrackingTests.swift
//  CoreUITests
//

import CoreBase
import CoreUI
import Testing

/// The names `error_shown` reports: stable, and never any error text.
struct AppErrorTrackingTests {

    @Test(arguments: [
        (AppError.network(.offline), "network.offline"),
        (.network(.timeout), "network.timeout"),
        (.network(.server), "network.server"),
        (.network(.decoding), "network.decoding"),
        (.storage, "storage"),
        (.unexpected("Pages start at 1, got 0"), "unexpected"),
    ])
    func trackingName(error: AppError, expected: String) {
        #expect(error.trackingName == expected)
    }
}
