//
//  CoreApi+InterfaceStubs.swift
//  CoreAPIStubs
//

import CoreAPI

@MainActor
public let coreApiStubsExports: CoreApiStubsExports = CoreApiStubsExportsImpl()

// MARK: - Exports

public protocol CoreApiStubsExports: Sendable {

    var apiManager: ApiManager { get }
}

// MARK: - ExportsImpl

struct CoreApiStubsExportsImpl: CoreApiStubsExports {

    let apiManager: ApiManager = ApiManagerStubs()
}
