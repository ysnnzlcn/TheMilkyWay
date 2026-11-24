//
//  SystemImage.swift
//  CoreAssets
//

import Foundation

/// Every SF Symbol the app draws. Components take a `SystemImage`, never a symbol name as a string.
/// Add a case before using a new symbol.
public enum SystemImage: String, Sendable {

    case building = "building.2"
    case calendar
    case camera
    case checkmarkCircleFill = "checkmark.circle.fill"
    case exclamationmarkCircleFill = "exclamationmark.circle.fill"
    case exclamationmarkTriangle = "exclamationmark.triangle"
    case magnifyingglass
    case photo
    case wifiSlash = "wifi.slash"
}
