//
//  AppInterface+CoreAPI.swift
//  TheMilkyWay
//

import CoreAPI
import CoreAPIStubs
private import CoreAPIImpl

extension AppInterface {

    @MainActor
    static func setupCoreAPIModule(_ apiEnvironment: ApiEnvironment) -> ApiManager {
        switch apiEnvironment {
        case .stubs: CoreAPIStubs.coreApiStubsExports.apiManager
        case .live: CoreAPIImpl.coreApiImplExports.apiManager
        }
    }
}
