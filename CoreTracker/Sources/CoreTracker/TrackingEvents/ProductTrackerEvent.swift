//
//  ProductTrackerEvent.swift
//  CoreTracker
//

/// What the person did.
public enum ProductTrackerEvent: Trackable, Equatable, Sendable {

    /// - Parameter imageID: NASA's public image id.
    case favoriteAdded(imageID: String)
    case favoriteRemoved(imageID: String)
    /// A search was sent. Only the query's length, never its text (it can hold personal data).
    case search(queryLength: Int)

    public var eventName: String {
        switch self {
        case .favoriteAdded: "favorite_added"
        case .favoriteRemoved: "favorite_removed"
        case .search: "search"
        }
    }

    public var params: [String: String] {
        switch self {
        case let .favoriteAdded(imageID), let .favoriteRemoved(imageID): ["image_id": imageID]
        case let .search(queryLength): ["query_length": String(queryLength)]
        }
    }
}
