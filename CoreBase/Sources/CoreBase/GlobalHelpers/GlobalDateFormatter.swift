//
//  GlobalDateFormatter.swift
//  CoreBase
//

import Foundation

/// Every date the app shows, in the phone's locale, so all screens agree. `locale` and `timeZone` are for tests.
public enum GlobalDateFormatter {

    /// "Mar 20, 2002" in English.
    public static func date(_ date: Date, locale: Locale = .current, timeZone: TimeZone = .current) -> String {
        date.formatted(Date.FormatStyle(date: .abbreviated, time: .omitted, locale: locale, timeZone: timeZone))
    }
}
