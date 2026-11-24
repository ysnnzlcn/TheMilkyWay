//
//  ApiManager.swift
//  CoreAPI
//

import CoreBase

/// Every API the app uses, built once at launch by the app target.
public protocol ApiManager: Sendable {
    var imageSearch: ImageSearchApi { get }
}

public struct ApiManagerUnimplemented: ApiManager {

    public init() { }

    public let imageSearch: ImageSearchApi = ImageSearchApiUnimplemented()
}
