//
//  ImageDetailsView.swift
//  ImageDetails
//

import ComposableArchitecture
import CoreAssets
import CoreBase
import CoreTracker
import CoreUI
import SwiftUI

/// The whole image on top (about half the screen), then the title, the favorite button, date, center and credit,
/// and the description.
public struct ImageDetailsView: View {

    private let store: StoreOf<ImageDetailsCore>

    public init(store: StoreOf<ImageDetailsCore>) {
        self.store = store
    }

    public var body: some View {
        BaseContentView(screen: .imageDetails) {
            ScrollView {
                VStack(alignment: .leading, spacing: DS.Spacing.lg) {
                    RemoteImage(
                        url: image.imageURL ?? image.thumbnailURL,
                        contentMode: .fit,
                        accessibilityLabel: image.title
                    )
                    .containerRelativeFrame(.vertical) { height, _ in height * 0.45 }
                    .frame(maxWidth: .infinity)
                    info
                        .padding(.horizontal, DS.Spacing.lg)
                }
                .padding(.bottom, DS.Spacing.xl)
            }
        }
        .toast(model: toast)
        // Only this screen's own save buzzes, not a change made in the other tab.
        .sensoryFeedback(.success, trigger: store.confirmation) { _, confirmation in confirmation != nil }
        .navigationBarTitleDisplayMode(.inline)
        .onFirstAppear { store.send(.onFirstAppear) }
    }

    private var image: NASAImageDTO { store.image }

    private var info: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            Text(image.title)
                .textStyle(.title)
                .foregroundStyle(DS.Colors.textPrimary)
            favoriteButton
            // Each kind of detail shows once; its text can repeat (center and credit both "NASA").
            ForEach(detailRows, id: \.icon) { row in
                Label(row.text, systemImage: row.icon)
                    .textStyle(.footnote)
                    .foregroundStyle(DS.Colors.textSecondary)
            }
            description
        }
    }

    @ViewBuilder
    private var favoriteButton: some View {
        if let isFavorite = store.isFavorite {
            FavoriteButton(isFavorite: isFavorite, isSaving: store.isSaving) { store.send(.onFavoriteTap) }
        }
    }

    @ViewBuilder
    private var description: some View {
        if let description = image.description {
            Text(description)
                .textStyle(.body)
                .foregroundStyle(DS.Colors.textPrimary)
                .textSelection(.enabled)
        }
    }
}

// MARK: UI mapping

private extension ImageDetailsView {

    struct DetailRow {
        let icon: SystemImage
        let text: String
    }

    /// A failed save, else the confirmation of a save, else nothing.
    var toast: ToastUIModel? {
        let onDismiss: () -> Void = { store.send(.onToastDismiss) }
        if let error = store.error {
            return ToastUIModel(error: error, onDismiss: onDismiss)
        }
        return store.confirmation.map { confirmation in
            let text = confirmation == .added ? L10n.ImageDetails.favoriteAdded : L10n.ImageDetails.favoriteRemoved
            return ToastUIModel(text: text, status: .confirmation, onDismiss: onDismiss)
        }
    }

    /// Only the details NASA sent.
    var detailRows: [DetailRow] {
        [
            image.dateCreated.map { DetailRow(icon: .calendar, text: GlobalDateFormatter.date($0)) },
            image.center.map { DetailRow(icon: .building, text: $0) },
            image.credit.map { DetailRow(icon: .camera, text: $0) },
        ].compactMap { $0 }
    }
}
