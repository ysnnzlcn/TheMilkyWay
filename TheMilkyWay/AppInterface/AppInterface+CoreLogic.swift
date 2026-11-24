//
//  AppInterface+CoreLogic.swift
//  TheMilkyWay
//

private import CoreLogicImpl

extension AppInterface {

    @MainActor
    static func setupCoreLogicModule() {
        CoreLogicImpl.coreLogicExports = CoreLogicExportsImpl()
    }
}
