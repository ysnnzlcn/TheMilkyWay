//
//  ErrorTrackerEvent.swift
//  CoreTracker
//

/// Errors the person saw.
public enum ErrorTrackerEvent: Trackable, Equatable, Sendable {

    /// An error toast or full-screen message appeared (sent by `Toast` and `HeaderMessage`).
    /// - Parameter error: the error's tracking name, e.g. `network.offline`.
    case errorShown(error: String, presentation: Presentation, screen: ScreenTrack?)

    public enum Presentation: String, Equatable, Sendable {
        case toast, header
    }

    public var eventName: String {
        switch self {
        case .errorShown: "error_shown"
        }
    }

    public var params: [String: String] {
        switch self {
        case let .errorShown(error, presentation, screen):
            var params = ["error": error, "presentation": presentation.rawValue]
            params["screen_name"] = screen?.name
            return params
        }
    }
}
