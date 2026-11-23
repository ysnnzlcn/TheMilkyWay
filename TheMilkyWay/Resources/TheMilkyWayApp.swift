//
//  TheMilkyWayApp.swift
//  TheMilkyWay
//

import SwiftUI

@main
struct TheMilkyWayApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            LegacyRootView()
                .ignoresSafeArea()
        }
    }
}
