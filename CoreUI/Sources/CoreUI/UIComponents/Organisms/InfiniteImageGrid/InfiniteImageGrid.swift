//
//  InfiniteImageGrid.swift
//  CoreUI
//

import SwiftUI

/// A scrolling two-column grid of `ImageCard`s that asks for more near its end, with a spinner under the last row
/// while the next page loads.
public struct InfiniteImageGrid: View {

    /// How many cards before the end the next page is asked for, so it is usually ready before the end is reached.
    static let prefetchDistance = 6

    private let items: [ImageCard.UIModel]
    private let isLoadingMore: Bool
    private let scrollResetID: AnyHashable?
    private let onTap: (String) -> Void
    private let onListEnd: () -> Void

    @State private var position = ScrollPosition(edge: .top)

    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: DS.Spacing.lg, alignment: .top),
        count: 2
    )

    /// - Parameters:
    ///   - scrollResetID: changing it scrolls back to the top, e.g. when a new search starts.
    ///   - onTap: the tapped card's `id`.
    ///   - onListEnd: one of the last cards appeared. Can be called several times; the caller ignores repeats.
    public init(
        items: [ImageCard.UIModel],
        isLoadingMore: Bool,
        scrollResetID: AnyHashable? = nil,
        onTap: @escaping (String) -> Void,
        onListEnd: @escaping () -> Void
    ) {
        self.items = items
        self.isLoadingMore = isLoadingMore
        self.scrollResetID = scrollResetID
        self.onTap = onTap
        self.onListEnd = onListEnd
    }

    public var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: DS.Spacing.lg) {
                ForEach(items) { item in
                    Button { onTap(item.id) } label: { ImageCard(model: item) }
                        .buttonStyle(.plain)
                        .onAppear { askForMoreIfNearEnd(item) }
                }
            }
            .padding(.horizontal, DS.Spacing.lg)
            .padding(.vertical, DS.Spacing.md)
            footer
        }
        .scrollPosition($position)
        .onChange(of: scrollResetID) { position.scrollTo(edge: .top) }
    }

    @ViewBuilder
    private var footer: some View {
        if isLoadingMore {
            ProgressView()
                .padding(.bottom, DS.Spacing.xl)
        }
    }

    private func askForMoreIfNearEnd(_ item: ImageCard.UIModel) {
        guard items.suffix(Self.prefetchDistance).contains(where: { $0.id == item.id }) else { return }
        onListEnd()
    }
}

#Preview {
    InfiniteImageGrid(
        items: (1...8).map { index in
            ImageCard.UIModel(
                id: "\(index)",
                title: "Nearside of the Moon \(index)",
                imageURL: URL(string: "https://images-assets.nasa.gov/image/PIA12235/PIA12235~thumb.jpg")
            )
        },
        isLoadingMore: true,
        onTap: { _ in },
        onListEnd: {}
    )
}
