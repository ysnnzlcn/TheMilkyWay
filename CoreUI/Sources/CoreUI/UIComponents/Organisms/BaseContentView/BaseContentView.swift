//
//  BaseContentView.swift
//  CoreUI
//

import CoreTracker
import SwiftUI

/// The container of every screen: background, the screen's `screen_view` when it appears, and while it loads, the
/// content dimmed and not tappable under a spinner. It also tells the `Toast` and `HeaderMessage` around it which
/// screen they are on, for tracking.
public struct BaseContentView<Content: View>: View {

    private let screen: ScreenTrack
    private let mode: ViewMode
    private let content: Content

    public init(screen: ScreenTrack, mode: ViewMode = .content, @ViewBuilder content: () -> Content) {
        self.screen = screen
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
        .onAppear { trackFromUI(.ui(.screenView(screen: screen))) }
        .preference(key: ShownScreenKey.self, value: screen)
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

/// The screen a `BaseContentView` shows, passed up to the `Toast` and `HeaderMessage` attached around it, so they
/// can track where they appeared. The innermost screen wins.
struct ShownScreenKey: PreferenceKey {

    static let defaultValue: ScreenTrack? = nil

    static func reduce(value: inout ScreenTrack?, nextValue: () -> ScreenTrack?) {
        value = value ?? nextValue()
    }
}

#Preview {
    BaseContentView(screen: .explore, mode: .loading) {
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
