//
//  CoreApi+InterfaceImpl.swift
//  CoreAPIImpl
//

import CoreAPI

@MainActor
public let coreApiImplExports: CoreApiImplExports = CoreApiImplExportsImpl()

// MARK: - Exports

public protocol CoreApiImplExports: Sendable {

    var apiManager: ApiManager { get }
}

// MARK: - ExportsImpl

struct CoreApiImplExportsImpl: CoreApiImplExports {

    let apiManager: ApiManager = ApiManagerImpl()
}
