//
//  StringExtensionTests.swift
//  
//
//  Created by Yasin Nazlican on 20.11.2021.
//

import XCTest
@testable import Core

class StringExtensionTests: XCTestCase {

    func test_whenStringFormatGiven_thenCheckIfThereIsValidDate() {
        let stabileDateString = "2002-03-20T00:00:00Z"
        XCTAssertNotNil(stabileDateString.toDate(format: "yyyy-MM-dd"))
        XCTAssertNotNil(stabileDateString.toDate(format: "yyyy-MM-dd HH"))
        XCTAssertNotNil(stabileDateString.toDate(format: "yyyy-MM-dd HH:MM"))
        XCTAssertNotNil(stabileDateString.toDate(format: "yyyy-MM-dd HH:mm:SS"))
        XCTAssertNil(stabileDateString.toDate(format: "yyyy"))
        XCTAssertNil(stabileDateString.toDate(format: "yyyy-MM"))
        XCTAssertNil(stabileDateString.toDate(format: "yyyy-MM-dd"))
    }
}
