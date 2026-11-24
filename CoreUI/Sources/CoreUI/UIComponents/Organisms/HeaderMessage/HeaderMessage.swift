//
//  HeaderMessage.swift
//  CoreUI
//

import CoreAssets
import CoreBase
import SwiftUI

public extension View {

    /// Covers the screen with `model`, e.g. a failed load with "Try again"; `nil` shows the content.
    func headerMessage(_ model: HeaderMessage.UIModel?) -> some View {
        modifier(HeaderMessage(model: model))
    }
}

/// A full-screen message over a screen's content: a failed load (with a retry button) or an empty state.
/// Built on the system's `ContentUnavailableView`.
public struct HeaderMessage: ViewModifier {

    public struct UIModel: Equatable {

        fileprivate let title: String
        fileprivate let description: String?
        fileprivate let systemImage: SystemImage
        fileprivate let buttonTitle: String?
        fileprivate let buttonAction: (() -> Void)?
        fileprivate let isError: Bool

        /// A failed load with the error's copy (`AppError+Strings`) and "Try again". `nil` when there is no error.
        public init?(error: AppError?, retry: @escaping () -> Void) {
            guard let error else { return nil }
            let copy = error.copy
            self.title = copy.title
            self.description = copy.description
            self.systemImage = copy.systemImage
            self.buttonTitle = copy.buttonTitle
            self.buttonAction = retry
            self.isError = true
        }

        /// An empty state, with an optional button.
        public init(
            title: String,
            description: String?,
            systemImage: SystemImage,
            buttonTitle: String? = nil,
            buttonAction: (() -> Void)? = nil
        ) {
            self.title = title
            self.description = description
            self.systemImage = systemImage
            self.buttonTitle = buttonTitle
            self.buttonAction = buttonAction
            self.isError = false
        }

        public static func == (lhs: UIModel, rhs: UIModel) -> Bool {
            lhs.title == rhs.title
                && lhs.description == rhs.description
                && lhs.systemImage == rhs.systemImage
                && lhs.buttonTitle == rhs.buttonTitle
        }
    }

    private let model: UIModel?

    public init(model: UIModel?) {
        self.model = model
    }

    public func body(content: Content) -> some View {
        content.overlay {
            ZStack {
                if let model {
                    message(model)
                }
            }
            .animation(.easeInOut(duration: DS.Motion.fast), value: model)
        }
    }

    private func message(_ model: UIModel) -> some View {
        ContentUnavailableView {
            Label(model.title, systemImage: model.systemImage)
        } description: {
            model.description.map { Text($0) }
        } actions: {
            if let buttonTitle = model.buttonTitle, let buttonAction = model.buttonAction {
                Button(buttonTitle, action: buttonAction)
                    .buttonStyle(.bordered)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DS.Colors.bg)
        .transition(.opacity)
        .onAppear { report(model) }
    }

    private func report(_ model: UIModel) {
        let text = [model.title, model.description].compactMap { $0 }.joined(separator: " / ")
        if model.isError {
            Log.warning("Error message: \(text)", .messages)
        } else {
            Log.info("Message: \(text)", .messages)
        }
    }
}

#Preview("Errors") {
    TabView {
        Tab("Offline", systemImage: SystemImage.wifiSlash.rawValue) {
            Color.clear.headerMessage(.init(error: .api(.offline)) {})
        }
        Tab("Other", systemImage: SystemImage.exclamationmarkTriangle.rawValue) {
            Color.clear.headerMessage(.init(error: .api(.server)) {})
        }
    }
}
