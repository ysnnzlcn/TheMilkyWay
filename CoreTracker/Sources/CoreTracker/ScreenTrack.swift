//
//  ScreenTrack.swift
//  CoreTracker
//

/// Every screen, as tracking and logs name it. A new screen adds its case.
public enum ScreenTrack: Equatable, Sendable {

    case explore
    case imageDetails
    case favorites

    /// The stable name in tracking and logs: never rename one.
    public var name: String {
        switch self {
        case .explore: "explore"
        case .imageDetails: "image_details"
        case .favorites: "favorites"
        }
    }
}
