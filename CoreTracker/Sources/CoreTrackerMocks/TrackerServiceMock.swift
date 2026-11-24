//
//  TrackerServiceMock.swift
//  CoreTrackerMocks
//

import CoreTracker
import Synchronization

/// For tests: records every event, in order.
public final class TrackerServiceMock: TrackerService {

    private let recorded = Mutex<[TrackerEvent]>([])

    public init() { }

    public var events: [TrackerEvent] {
        recorded.withLock { $0 }
    }

    public func track(_ event: TrackerEvent) {
        recorded.withLock { $0.append(event) }
    }
}
