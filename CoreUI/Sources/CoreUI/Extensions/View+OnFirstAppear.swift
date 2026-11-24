//
//  View+OnFirstAppear.swift
//  CoreUI
//

import SwiftUI

public extension View {

    /// Runs `action` only the first time the view appears, not when a pushed screen is popped back to it.
    func onFirstAppear(_ action: @escaping () -> Void) -> some View {
        modifier(OnFirstAppear(action: action))
    }
}

private struct OnFirstAppear: ViewModifier {

    let action: () -> Void

    @State private var hasAppeared = false

    func body(content: Content) -> some View {
        content.onAppear {
            guard !hasAppeared else { return }
            hasAppeared = true
            action()
        }
    }
}
