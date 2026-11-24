//
//  FavoriteButton.swift
//  CoreUI
//

import CoreAssets
import SwiftUI

/// "Add to Favorites" with an empty heart, or "Remove from Favorites" with a filled one. Full width; while saving it
/// shows a spinner and can't be tapped again. The screen plays the haptic when its save succeeds: the state can also
/// change from another screen, which must not buzz here.
public struct FavoriteButton: View {

    private let isFavorite: Bool
    private let isSaving: Bool
    private let onTap: () -> Void

    public init(isFavorite: Bool, isSaving: Bool, onTap: @escaping () -> Void) {
        self.isFavorite = isFavorite
        self.isSaving = isSaving
        self.onTap = onTap
    }

    public var body: some View {
        Button(action: onTap) {
            Label(title, systemImage: isFavorite ? .heartFill : .heart)
                .textStyle(.headline)
                .frame(maxWidth: .infinity)
                .opacity(isSaving ? 0 : 1)
                .overlay { spinner }
        }
        .buttonStyle(.bordered)
        .controlSize(.large)
        .tint(DS.Colors.accent)
        .disabled(isSaving)
        .animation(.easeInOut(duration: DS.Motion.fast), value: isFavorite)
    }

    private var title: String {
        isFavorite ? L10n.Coreui.favoriteButtonRemove : L10n.Coreui.favoriteButtonAdd
    }

    @ViewBuilder
    private var spinner: some View {
        if isSaving {
            ProgressView()
        }
    }
}

#Preview {
    VStack(spacing: DS.Spacing.lg) {
        FavoriteButton(isFavorite: false, isSaving: false) {}
        FavoriteButton(isFavorite: true, isSaving: false) {}
        FavoriteButton(isFavorite: true, isSaving: true) {}
    }
    .padding()
}
