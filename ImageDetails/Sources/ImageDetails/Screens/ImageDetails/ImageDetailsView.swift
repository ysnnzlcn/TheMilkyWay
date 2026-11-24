//
//  ImageDetailsView.swift
//  ImageDetails
//

import ComposableArchitecture
import CoreAssets
import CoreBase
import CoreUI
import SwiftUI

/// The whole image on top (about half the screen), then the title, date, center and credit, and the description.
public struct ImageDetailsView: View {

    private let store: StoreOf<ImageDetailsCore>

    public init(store: StoreOf<ImageDetailsCore>) {
        self.store = store
    }

    public var body: some View {
        BaseContentView {
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
        .navigationBarTitleDisplayMode(.inline)
    }

    private var image: NASAImageDTO { store.image }

    private var info: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            Text(image.title)
                .textStyle(.title)
                .foregroundStyle(DS.Colors.textPrimary)
            ForEach(detailRows, id: \.text) { row in
                Label(row.text, systemImage: row.icon)
                    .textStyle(.footnote)
                    .foregroundStyle(DS.Colors.textSecondary)
            }
            description
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

    /// Only the details NASA sent.
    var detailRows: [DetailRow] {
        [
            image.dateCreated.map { DetailRow(icon: .calendar, text: GlobalDateFormatter.date($0)) },
            image.center.map { DetailRow(icon: .building, text: $0) },
            image.credit.map { DetailRow(icon: .camera, text: $0) },
        ].compactMap { $0 }
    }
}
