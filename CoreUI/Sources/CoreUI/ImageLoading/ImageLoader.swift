//
//  ImageLoader.swift
//  CoreUI
//

import CoreBase
import Foundation
import ImageIO
import UIKit

/// Loads remote images for `RemoteImage`. Each image is decoded at the size it is drawn (not the file's full size),
/// kept in a memory cache, and its file in a disk cache (`URLCache`). Cancelling the calling task (the view went
/// off screen) cancels the download.
public final class ImageLoader: Sendable {

    public static let shared = ImageLoader()

    private let session: URLSession
    private let cache: ImageMemoryCache

    init(session: URLSession = ImageLoader.makeSession(), cache: ImageMemoryCache = ImageMemoryCache()) {
        self.session = session
        self.cache = cache
    }

    /// The image at `url`, at most `maxPixelSize` pixels on its longer side. `nil` when it can't be loaded.
    @concurrent
    public func image(for url: URL, maxPixelSize: Int) async -> UIImage? {
        let key = "\(maxPixelSize)|\(url.absoluteString)"
        if let image = cache[key] { return image }

        do {
            let (data, response) = try await session.data(from: url)
            let status = (response as? HTTPURLResponse)?.statusCode ?? 0
            guard (200...299).contains(status) else {
                Log.warning("Image failed with status \(status)", .images)
                return nil
            }
            try Task.checkCancellation()
            guard let image = Self.downsample(data, maxPixelSize: maxPixelSize) else {
                Log.warning("Image data could not be decoded", .images)
                return nil
            }
            cache[key] = image
            return image
        } catch {
            // Cancelling is normal: the image scrolled off screen.
            if !(error is CancellationError), (error as? URLError)?.code != .cancelled {
                Log.warning("Image failed: \((error as? URLError)?.code.rawValue ?? 0)", .images)
            }
            return nil
        }
    }

    // MARK: Private

    /// Decodes straight to the smaller size, so a large photo never sits in memory at full size.
    static func downsample(_ data: Data, maxPixelSize: Int) -> UIImage? {
        let sourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let source = CGImageSourceCreateWithData(data as CFData, sourceOptions) else { return nil }
        let options = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceThumbnailMaxPixelSize: max(1, maxPixelSize),
        ] as CFDictionary
        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, options) else { return nil }
        return UIImage(cgImage: cgImage)
    }

    /// Image files never change at their address, so a cached file is used without asking the server again.
    private static func makeSession() -> URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = URLCache(
            memoryCapacity: 0,
            diskCapacity: 200 * 1024 * 1024,
            directory: URL.cachesDirectory.appending(path: "Images")
        )
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        return URLSession(configuration: configuration)
    }
}

/// Decoded images by key, limited by their size in memory. `NSCache` is thread-safe and empties itself under
/// memory pressure.
final class ImageMemoryCache: @unchecked Sendable {

    private let cache = NSCache<NSString, UIImage>()

    init(byteLimit: Int = 64 * 1024 * 1024) {
        cache.totalCostLimit = byteLimit
    }

    subscript(key: String) -> UIImage? {
        get { cache.object(forKey: key as NSString) }
        set {
            guard let newValue else {
                cache.removeObject(forKey: key as NSString)
                return
            }
            let bytes = newValue.cgImage.map { $0.bytesPerRow * $0.height } ?? 0
            cache.setObject(newValue, forKey: key as NSString, cost: bytes)
        }
    }
}
