//
//  HeaderMessage.swift
//  CoreUI
//

import CoreAssets
import CoreBase
import CoreTracker
import SwiftUI

public extension View {

    /// Covers the screen with `model`, e.g. a failed load with "Try again"; `nil` shows the content.
    func headerMessage(_ model: HeaderMessage.UIModel?) -> some View {
        modifier(HeaderMessage(model: model))
    }
}

/// A full-screen message over a screen's content: a failed load with "Try again", or an empty state with no button.
/// Built on the system's `ContentUnavailableView`.
public struct HeaderMessage: ViewModifier {

    public struct UIModel: Equatable {

        fileprivate let title: String
        fileprivate let description: String?
        fileprivate let systemImage: SystemImage
        /// "Try again" on a failed load; `nil` for an empty state.
        fileprivate let retry: (() -> Void)?
        /// What went wrong, for tracking; `nil` for an empty state.
        fileprivate let error: AppError?

        /// A failed load with the error's copy (`AppError+Strings`) and "Try again". `nil` when there is no error.
        public init?(error: AppError?, retry: @escaping () -> Void) {
            guard let error else { return nil }
            let copy = error.copy
            self.title = copy.title
            self.description = copy.description
            self.systemImage = copy.systemImage
            self.retry = retry
            self.error = error
        }

        /// An empty state.
        public init(title: String, description: String?, systemImage: SystemImage) {
            self.title = title
            self.description = description
            self.systemImage = systemImage
            self.retry = nil
            self.error = nil
        }

        fileprivate var isError: Bool { error != nil }

        public static func == (lhs: UIModel, rhs: UIModel) -> Bool {
            lhs.title == rhs.title
                && lhs.description == rhs.description
                && lhs.systemImage == rhs.systemImage
                && lhs.isError == rhs.isError
        }
    }

    private let model: UIModel?

    public init(model: UIModel?) {
        self.model = model
    }

    public func body(content: Content) -> some View {
        // The screen comes from the `BaseContentView` inside, for tracking.
        content.overlayPreferenceValue(ShownScreenKey.self) { screen in
            ZStack {
                if let model {
                    message(model, on: screen)
                }
            }
            .animation(.easeInOut(duration: DS.Motion.fast), value: model)
        }
    }

    private func message(_ model: UIModel, on screen: ScreenTrack?) -> some View {
        ContentUnavailableView {
            Label(model.title, systemImage: model.systemImage)
        } description: {
            model.description.map { Text($0) }
        } actions: {
            if let retry = model.retry {
                Button(L10n.Errors.retry, action: retry)
                    .buttonStyle(.bordered)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // Covers the content only: by default a background reaches into the safe area and hides the large title.
        .background(DS.Colors.bg, ignoresSafeAreaEdges: [])
        .transition(.opacity)
        .onAppear { report(model, on: screen) }
    }

    /// Every message is logged; a failed load is also tracked.
    private func report(_ model: UIModel, on screen: ScreenTrack?) {
        let text = [model.title, model.description].compactMap { $0 }.joined(separator: " / ")
        guard let error = model.error else {
            Log.info("Message: \(text)", .messages)
            return
        }
        Log.warning("Error message: \(text)", .messages)
        trackFromUI(.error(.errorShown(error: error.trackingName, presentation: .header, screen: screen)))
    }
}

#Preview("Errors") {
    TabView {
        Tab("Offline", systemImage: SystemImage.wifiSlash.rawValue) {
            Color.clear.headerMessage(.init(error: .network(.offline)) {})
        }
        Tab("Other", systemImage: SystemImage.exclamationmarkTriangle.rawValue) {
            Color.clear.headerMessage(.init(error: .network(.server)) {})
        }
    }
}
