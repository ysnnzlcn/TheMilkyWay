//
//  TemporaryImageCache.swift
//  
//
//  Created by Yasin Nazlican on 18.11.2021.
//

import UIKit

/// `NSCache` is thread-safe and is the only stored state.
final public class TemporaryImageCache: @unchecked Sendable {

    // MARK: Shared
    
    public static let shared = TemporaryImageCache()

    // MARK: Private Variables

    private let cache = NSCache<NSURL, UIImage>()

    // MARK: Life-Cycle

    public init() { }

    // MARK: Subscript

    public subscript(_ key: URL) -> UIImage? {
        get {
            cache.object(forKey: key as NSURL)
        }
        set {
            if newValue == nil {
                cache.removeObject(forKey: key as NSURL)
            } else {
                cache.setObject(newValue!, forKey: key as NSURL)
            }
        }
    }
}
