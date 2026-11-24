//
//  ImageCard.swift
//  CoreUI
//

import CoreBase
import SwiftUI

/// A square image with its title under it, on two lines (space kept, so cards in a row line up). The whole card is
/// its tap area, picture included.
public struct ImageCard: View {

    public struct UIModel: Identifiable, Equatable, Sendable {
        public let id: String
        public let title: String
        public let imageURL: URL?

        public init(id: String, title: String, imageURL: URL?) {
            self.id = id
            self.title = title
            self.imageURL = imageURL
        }

        /// The card for an image: its title and small preview. Every grid of images uses this.
        public init(image: NASAImageDTO) {
            self.init(id: image.id, title: image.title, imageURL: image.thumbnailURL)
        }
    }

    private let model: UIModel

    public init(model: UIModel) {
        self.model = model
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            RemoteImage(url: model.imageURL)
                .aspectRatio(1, contentMode: .fit)
                .clipShape(.rect(cornerRadius: DS.Radius.md))
            Text(model.title)
                .textStyle(.subhead)
                .foregroundStyle(DS.Colors.textPrimary)
                .lineLimit(2, reservesSpace: true)
                .multilineTextAlignment(.leading)
        }
        // A loaded image has no tappable background of its own; the card's whole frame takes taps.
        .contentShape(.rect)
        // VoiceOver reads the title once; the image is decorative here.
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    HStack(alignment: .top, spacing: DS.Spacing.lg) {
        ImageCard(model: .init(id: "1", title: "Nearside of the Moon", imageURL: .previewImage))
        ImageCard(model: .init(id: "2", title: "A very long title that needs more than two lines", imageURL: nil))
    }
    .padding()
}
