//
//  TrackerProvider.swift
//  CoreTrackerImpl
//

import CoreTracker

/// One analytics destination. `TrackerServiceImpl` sends every event to each provider, so adding or replacing a
/// destination is one new provider here and nothing else in the app.
protocol TrackerProvider: Sendable {
    func track(_ event: TrackerEvent)
}
