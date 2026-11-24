//
//  RemoteImage.swift
//  CoreUI
//

import CoreAssets
import SwiftUI
import UIKit

/// Every image loaded from the network, in the frame the caller sets. `.fill` crops to the frame (the caller clips);
/// `.fit` shows the whole image. Loading: placeholder color. Loaded: the image fades in. Failed: placeholder with a
/// photo glyph.
public struct RemoteImage: View {

    private let url: URL?
    private let contentMode: ContentMode
    private let accessibilityLabel: String?

    @Environment(\.displayScale) private var displayScale
    @State private var size: CGSize = .zero
    @State private var phase: Phase = .loading

    /// - Parameter accessibilityLabel: `nil` for decorative images; set it when the image carries content.
    public init(url: URL?, contentMode: ContentMode = .fill, accessibilityLabel: String? = nil) {
        self.url = url
        self.contentMode = contentMode
        self.accessibilityLabel = accessibilityLabel
    }

    public var body: some View {
        Color.clear
            .background(shownPhase.url == nil ? DS.Colors.placeholder : .clear)
            .overlay { content }
            // Its frame takes taps (e.g. inside a card's button); `Color.clear` alone takes none once loaded.
            .contentShape(.rect)
            .onGeometryChange(for: CGSize.self) { $0.size } action: { size = $0 }
            .task(id: request) { await load(request) }
            .animation(.easeInOut(duration: DS.Motion.base), value: phase)
            .accessibilityElement()
            .accessibilityLabel(accessibilityLabel ?? "")
            .accessibilityAddTraits(.isImage)
            .accessibilityHidden(accessibilityLabel == nil)
    }

    /// `phase`, or an image already in memory while it is still loading: a card scrolled back on screen shows its
    /// image at once instead of fading in again (the fade follows `phase` only).
    private var shownPhase: Phase {
        guard case .loading = phase, let url = request.url, request.maxPixelSize > 0 else { return phase }
        let cached = ImageLoader.shared.cachedImage(for: url, maxPixelSize: request.maxPixelSize)
        return cached.map { .loaded($0, url: url) } ?? phase
    }

    @ViewBuilder
    private var content: some View {
        switch shownPhase {
        case .loading:
            EmptyView()
        case .loaded(let image, _):
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: contentMode)
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
