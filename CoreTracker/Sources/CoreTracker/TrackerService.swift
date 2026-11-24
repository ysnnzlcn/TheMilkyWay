//
//  TrackerService.swift
//  CoreTracker
//

/// Sends what happened in the app to every analytics provider. Names no provider: replacing one changes only
/// `CoreTrackerImpl`.
public protocol TrackerService: Sendable {

    /// Synchronous, so providers receive events in the order they happened.
    func track(_ event: TrackerEvent)
}

/// The default before the app wires the real service: any use is a bug.
public struct TrackerServiceUnimplemented: TrackerService {

    public init() { }

    public func track(_ event: TrackerEvent) {
        fatalError("Not implemented")
    }
}
