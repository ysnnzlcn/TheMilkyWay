//
//  BaseContentView.swift
//  CoreUI
//

import SwiftUI

/// The container of every screen: background, and no taps on the content while it loads.
public struct BaseContentView<Content: View>: View {

    private let mode: ViewMode
    private let content: Content

    public init(mode: ViewMode = .content, @ViewBuilder content: () -> Content) {
        self.mode = mode
        self.content = content()
    }

    public var body: some View {
        ZStack(alignment: .top) {
            DS.Colors.bg
                .ignoresSafeArea()

            content
                // While loading, the content can't be used.
                .allowsHitTesting(mode != .loading)
        }
        .animation(.easeInOut(duration: DS.Motion.fast), value: mode)
    }
}

// MARK: - Models

public enum ViewMode: Equatable, Sendable {

    /// A request is running: the content is not interactive.
    case loading

    /// The content is shown and usable.
    case content
}
