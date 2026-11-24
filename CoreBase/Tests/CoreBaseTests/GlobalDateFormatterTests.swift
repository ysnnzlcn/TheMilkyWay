//
//  GlobalDateFormatterTests.swift
//  CoreBaseTests
//

import Foundation
import Testing
import CoreBase

struct GlobalDateFormatterTests {

    private let date = Date(timeIntervalSince1970: 1_016_582_400) // 2002-03-20 00:00 UTC
    private let utc = TimeZone(identifier: "UTC") ?? .gmt

    @Test(arguments: [
        ("en_US", "Mar 20, 2002"),
        ("en_GB", "20 Mar 2002"),
        ("tr_TR", "20 Mar 2002"),
    ])
    func dateUsesLocale(identifier: String, expected: String) {
        let text = GlobalDateFormatter.date(date, locale: Locale(identifier: identifier), timeZone: utc)

        #expect(text == expected)
    }

    @Test func dateUsesTimeZone() {
        let newYork = TimeZone(identifier: "America/New_York") ?? .gmt

        let text = GlobalDateFormatter.date(date, locale: Locale(identifier: "en_US"), timeZone: newYork)

        #expect(text == "Mar 19, 2002")
    }
}
