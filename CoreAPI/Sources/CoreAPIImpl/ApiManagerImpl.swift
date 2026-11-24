//
//  ApiManagerImpl.swift
//  CoreAPIImpl
//

import CoreAPI

struct ApiManagerImpl: ApiManager {

    let imageSearch: ImageSearchApi = ImageSearchApiImpl()
}
