//
//  RemoteImage.swift
//  CoreUI
//

import CoreAssets
import SwiftUI
import UIKit

/// Every image loaded from the network. It fills its frame; the caller sets the frame and clips it.
/// Loading: placeholder color. Loaded: the image fades in. Failed: placeholder with a photo glyph.
public struct RemoteImage: View {

    private let url: URL?
    private let accessibilityLabel: String?

    @Environment(\.displayScale) private var displayScale
    @State private var size: CGSize = .zero
    @State private var phase: Phase = .loading

    /// - Parameter accessibilityLabel: `nil` for decorative images; set it when the image carries content.
    public init(url: URL?, accessibilityLabel: String? = nil) {
        self.url = url
        self.accessibilityLabel = accessibilityLabel
    }

    public var body: some View {
        DS.Colors.placeholder
            .overlay { content }
            .onGeometryChange(for: CGSize.self) { $0.size } action: { size = $0 }
            .task(id: request) { await load(request) }
            .animation(.easeInOut(duration: DS.Motion.base), value: phase)
            .accessibilityElement()
            .accessibilityLabel(accessibilityLabel ?? "")
            .accessibilityAddTraits(.isImage)
            .accessibilityHidden(accessibilityLabel == nil)
    }

    @ViewBuilder
    private var content: some View {
        switch phase {
        case .loading:
            EmptyView()
        case .loaded(let image, _):
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                // A filled image overflows its frame; it must not take taps outside it.
                .allowsHitTesting(false)
        case .failed:
            Image(systemImage: .photo)
                .textStyle(.title)
                .foregroundStyle(DS.Colors.placeholderIcon)
        }
    }

    /// The pixels needed on screen, rounded up to steps of 100, so small layout changes don't reload.
    private var request: Request {
        let longerSide = max(size.width, size.height) * displayScale
        let step = 100.0
        return Request(url: url, maxPixelSize: Int((longerSide / step).rounded(.up) * step))
    }

    private func load(_ request: Request) async {
        guard let url = request.url else {
            phase = .failed
            return
        }
        guard request.maxPixelSize > 0 else { return }
        // A new address starts over; a new size keeps showing the old image until the sharper one arrives.
        if phase.url != url { phase = .loading }

        let image = await ImageLoader.shared.image(for: url, maxPixelSize: request.maxPixelSize)
        guard !Task.isCancelled else { return }
        phase = image.map { .loaded($0, url: url) } ?? .failed
    }
}

// MARK: Models

private extension RemoteImage {

    struct Request: Equatable {
        let url: URL?
        let maxPixelSize: Int
    }

    enum Phase: Equatable {
        case loading
        case loaded(UIImage, url: URL)
        case failed

        var url: URL? {
            guard case .loaded(_, let url) = self else { return nil }
            return url
        }
    }
}

#Preview {
    HStack(spacing: DS.Spacing.lg) {
        RemoteImage(url: URL(string: "https://images-assets.nasa.gov/image/PIA12235/PIA12235~thumb.jpg"))
            .frame(width: 120, height: 120)
            .clipShape(.rect(cornerRadius: DS.Radius.md))
        RemoteImage(url: nil)
            .frame(width: 120, height: 120)
            .clipShape(.rect(cornerRadius: DS.Radius.md))
    }
    .padding()
}
