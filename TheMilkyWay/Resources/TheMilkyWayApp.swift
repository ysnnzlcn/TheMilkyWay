//
//  TheMilkyWayApp.swift
//  TheMilkyWay
//

import CoreBase
import SwiftUI

@main
struct TheMilkyWayApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
        AppInterface.setup(.current)
    }

    var body: some Scene {
        WindowGroup {
            LegacyRootView()
                .ignoresSafeArea()
        }
    }
}

extension AppEnvironment {

    /// This build's environment, from the `DEBUG` flag of the project's Debug settings. Read here because
    /// packages don't see the app's flags.
    static var current: AppEnvironment {
        #if DEBUG
        .debug
        #else
        .release
        #endif
    }
}
