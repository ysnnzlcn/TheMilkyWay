//
//  Date+Extensions.swift
//  
//
//  Created by Yasin Nazlican on 20.11.2021.
//

import Foundation

extension Date {

    public func toString(
        format: String = "yyyy-MM-dd HH:mm",
        timeZone: TimeZone = .current,
        locale: Locale = .current
    ) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = locale
        dateFormatter.timeZone = timeZone
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}
