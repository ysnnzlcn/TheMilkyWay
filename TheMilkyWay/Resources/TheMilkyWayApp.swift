//
//  TheMilkyWayApp.swift
//  TheMilkyWay
//

import ComposableArchitecture
import CoreBase
import SwiftUI

@main
struct TheMilkyWayApp: App {

    /// Created on first use, after `AppInterface.setup` in `init`.
    static let appState = Store(initialState: AppState.State()) {
        AppState()
    }

    /// Tests in the app target launch the real app next to them. While they run, the app sets nothing up (no store
    /// on disk is opened) and shows nothing.
    private static let isRunningTests = TestContext.current != nil

    init() {
        guard !Self.isRunningTests else { return }
        AppInterface.setup(.current)
    }

    var body: some Scene {
        WindowGroup {
            if !Self.isRunningTests {
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
