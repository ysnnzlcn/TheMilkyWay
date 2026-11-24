//
//  LogTrackerProvider.swift
//  CoreTrackerImpl
//

import CoreBase
import CoreTracker

/// Writes every event to the log (category `tracker`), e.g. `screen_view {screen_name: explore}`, so tracking can be
/// checked in Console.app without an analytics account.
struct LogTrackerProvider: TrackerProvider {

    func track(_ event: TrackerEvent) {
        Log.info(Self.text(for: event), .tracker)
    }

    /// The event's name and its parameters, sorted by key so the same event always reads the same.
    static func text(for event: TrackerEvent) -> String {
        let trackable = event.asTrackable
        let params = trackable.params
            .sorted { $0.key < $1.key }
            .map { "\($0.key): \($0.value)" }
            .joined(separator: ", ")
        return "\(trackable.eventName) {\(params)}"
    }
}
