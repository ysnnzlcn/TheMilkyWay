//
//  Log.swift
//  CoreBase
//

import Foundation
import os

/// The app's logger: `os.Logger` with one category per module or service, so Console.app can filter by it.
/// Messages are public: never log personal data.
public enum Log {

    public enum Category: String, Sendable {
        case app
        case home
        /// Toasts and full-screen messages shown, with their text.
        case messages
        case api
        case images
    }

    public static func debug(_ message: String, _ category: Category, file: String = #fileID, line: Int = #line) {
        log(.debug, message, category, file: file, line: line)
    }

    public static func info(_ message: String, _ category: Category, file: String = #fileID, line: Int = #line) {
        log(.info, message, category, file: file, line: line)
    }

    public static func warning(_ message: String, _ category: Category, file: String = #fileID, line: Int = #line) {
        log(.default, message, category, file: file, line: line)
    }

    public static func error(_ message: String, _ category: Category, file: String = #fileID, line: Int = #line) {
        log(.error, message, category, file: file, line: line)
    }

    /// One public string, so the file and line aren't hidden as `<private>` without a debugger attached.
    private static func log(_ level: OSLogType, _ message: String, _ category: Category, file: String, line: Int) {
        let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "TheMilkyWay", category: category.rawValue)
        let text = "\(file):\(line) \(message)"
        logger.log(level: level, "\(text, privacy: .public)")
    }
}
