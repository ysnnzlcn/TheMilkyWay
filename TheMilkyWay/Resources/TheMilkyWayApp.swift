//
//  TheMilkyWayApp.swift
//  TheMilkyWay
//

import ComposableArchitecture
import CoreBase
import SwiftUI

@main
struct TheMilkyWayApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    /// Created on first use, after `AppInterface.setup` in `init`.
    static let appState = Store(initialState: AppState.State()) {
        AppState()
    }

    init() {
        AppInterface.setup(.current)
    }

    var body: some Scene {
        WindowGroup {
            // Tests in the app target launch the real app next to them; its work would then use dependencies in a
            // test context. While tests run, the app shows nothing.
            if TestContext.current == nil {
                AppView(store: Self.appState)
            }
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
