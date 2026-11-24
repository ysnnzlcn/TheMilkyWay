//
//  UITrackerEvent.swift
//  CoreTracker
//

/// What the person saw.
public enum UITrackerEvent: Trackable, Equatable, Sendable {

    /// A screen appeared (sent by `BaseContentView`).
    case screenView(screen: ScreenTrack)

    public var eventName: String {
        switch self {
        case .screenView: "screen_view"
        }
    }

    public var params: [String: String] {
        switch self {
        case let .screenView(screen): ["screen_name": screen.name]
        }
    }
}
