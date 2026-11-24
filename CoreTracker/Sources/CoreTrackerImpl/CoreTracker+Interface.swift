//
//  CoreTracker+Interface.swift
//  CoreTrackerImpl
//

import CoreTracker

@MainActor
public let coreTrackerExports: CoreTrackerExports = CoreTrackerExportsImpl()

// MARK: - Exports

public protocol CoreTrackerExports: Sendable {
    var trackerService: TrackerService { get }
}

// MARK: - ExportsImpl

struct CoreTrackerExportsImpl: CoreTrackerExports {

    /// The log for now; Firebase is ready to be filled in (`FirebaseTrackerProvider`).
    let trackerService: TrackerService = TrackerServiceImpl(providers: [
        LogTrackerProvider(),
        FirebaseTrackerProvider(),
    ])
}
