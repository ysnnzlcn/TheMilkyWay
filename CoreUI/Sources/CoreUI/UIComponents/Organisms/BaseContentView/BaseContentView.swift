//
//  BaseContentView.swift
//  CoreUI
//

import SwiftUI

/// The container of every screen: background, and while it loads, the content dimmed and not tappable under a
/// spinner.
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
                .opacity(mode == .loading ? DS.Opacity.dimmed : 1)
                // While loading, the content can't be used.
                .allowsHitTesting(mode != .loading)
        }
        .overlay { loadingIndicator }
        .animation(.easeInOut(duration: DS.Motion.fast), value: mode)
    }

    @ViewBuilder
    private var loadingIndicator: some View {
        if mode == .loading {
            ProgressView()
                .controlSize(.large)
        }
    }
}

#Preview {
    BaseContentView(mode: .loading) {
        Text("Content")
            .textStyle(.title)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Models

public enum ViewMode: Equatable, Sendable {

    /// A request is running: the content is not interactive.
    case loading

    /// The content is shown and usable.
    case content
}
