//
//  DateExtensionTests.swift
//  
//
//  Created by Yasin Nazlican on 20.11.2021.
//

import XCTest
@testable import Core

class DateExtensionTests: XCTestCase {

    func test_whenStringGiven_thenCheckOutput() {
        let stabileDate = "2002-03-20T00:00:00Z".toDate() // This is tested in its own.
        XCTAssertNotNil(stabileDate)

        // Fixed time zone and locale, so the result is the same on every machine.
        let utc = TimeZone(secondsFromGMT: 0) ?? .gmt
        let locale = Locale(identifier: "en_US_POSIX")
        let formatted = { (format: String) in
            stabileDate?.toString(format: format, timeZone: utc, locale: locale)
        }

        XCTAssertEqual(formatted("yyyy-MM-dd HH:mm"), "2002-03-20 00:00")
        XCTAssertEqual(formatted("yyyy-MM-dd"), "2002-03-20")
        XCTAssertEqual(formatted("yyyy, MM, dd"), "2002, 03, 20")
        XCTAssertEqual(formatted("yyyy-MMM-dd"), "2002-Mar-20")
        XCTAssertEqual(formatted("yyyy-MM-dd HH:mm:ss"), "2002-03-20 00:00:00")
        XCTAssertEqual(formatted("yyyy-MM-dd HH-mm"), "2002-03-20 00-00")
    }
}
