//
//  CoreUI+Interface.swift
//  CoreUI
//

import CoreTracker
import Foundation

/// What this module needs. The app replaces it at launch (`AppInterface+CoreUI`).
@MainActor
public var coreUIImports: CoreUIImports = CoreUIImportsImpl(trackerService: TrackerServiceUnimplemented())

/// How CoreUI components track. Skipped while Xcode renders previews, which wire no tracker.
@MainActor
func trackFromUI(_ event: TrackerEvent) {
    guard ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != "1" else { return }
    coreUIImports.trackerService.track(event)
}

// MARK: Imports

public protocol CoreUIImports: Sendable {
    /// Screen views (`BaseContentView`) and shown errors (`Toast`, `HeaderMessage`).
    var trackerService: TrackerService { get }
}

// MARK: ImportsImpl

public struct CoreUIImportsImpl: CoreUIImports {

    public let trackerService: TrackerService

    public init(trackerService: TrackerService) {
        self.trackerService = trackerService
    }
}
