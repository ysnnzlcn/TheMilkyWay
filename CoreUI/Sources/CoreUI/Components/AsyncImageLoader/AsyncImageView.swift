//
//  AsyncImageView.swift
//
//
//  Created by Yasin Nazlican on 18.11.2021.
//

import UIKit

public class AsyncImageView: UIImageView {

    // MARK: Private Variables

    private var loadTask: Task<Void, Never>?

    // MARK: Public Variables

    public private(set) var isLoading = false

    // MARK: Public Methods

    public func load(url: URL, cache: TemporaryImageCache) {
        cancelLoading()

        if let image = cache[url] {
            self.image = image
            return
        }

        isLoading = true
        loadTask = Task { [weak self] in
            let image = await Self.fetchImage(url: url, cache: cache)
            guard !Task.isCancelled else { return }
            self?.image = image
            self?.isLoading = false
        }
    }

    public func cancelLoading() {
        loadTask?.cancel()
        loadTask = nil
        isLoading = false
    }

    // MARK: Private Methods

    private nonisolated static func fetchImage(url: URL, cache: TemporaryImageCache) async -> UIImage? {
        guard let (data, _) = try? await URLSession.shared.data(from: url) else { return nil }
        guard let image = UIImage(data: data) else { return nil }
        cache[url] = image
        return image
    }

    isolated deinit {
        loadTask?.cancel()
    }
}
