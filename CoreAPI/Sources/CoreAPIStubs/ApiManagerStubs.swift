//
//  ApiManagerStubs.swift
//  CoreAPIStubs
//

import CoreAPI

public struct ApiManagerStubs: ApiManager {

    public init() { }

    public let imageSearch: ImageSearchApi = ImageSearchApiStubs()
}
