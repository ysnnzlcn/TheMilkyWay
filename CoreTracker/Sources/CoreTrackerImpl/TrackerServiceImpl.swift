//
//  TrackerServiceImpl.swift
//  CoreTrackerImpl
//

import CoreTracker

/// Sends every event to each provider, in the order they are listed.
struct TrackerServiceImpl: TrackerService {

    private let providers: [any TrackerProvider]

    init(providers: [any TrackerProvider]) {
        self.providers = providers
    }

    func track(_ event: TrackerEvent) {
        providers.forEach { $0.track(event) }
    }
}
