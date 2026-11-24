//
//  TrackerEvent.swift
//  CoreTracker
//

/// Every event, grouped by kind. An event is an enum case; its associated values (plain values, never personal
/// data) are its parameters. Names are snake_case object_action.
public enum TrackerEvent: Equatable, Sendable {
    case ui(UITrackerEvent)
    case error(ErrorTrackerEvent)
    case product(ProductTrackerEvent)

    public var asTrackable: any Trackable {
        switch self {
        case let .ui(event): event
        case let .error(event): event
        case let .product(event): event
        }
    }
}

/// What a provider sends: a name and its parameters.
public protocol Trackable: Sendable {
    var eventName: String { get }
    var params: [String: String] { get }
}
