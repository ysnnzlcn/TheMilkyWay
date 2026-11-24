//
//  LegacyRootView.swift
//  TheMilkyWay
//

import SwiftUI

/// Hosts the UIKit screens until they move to SwiftUI + TCA.
struct LegacyRootView: UIViewControllerRepresentable {

    func makeCoordinator() -> AppCoordinator {
        AppCoordinator(imageSearchApi: mainTargetImports.apiManager.imageSearch)
    }

    func makeUIViewController(context: Context) -> UINavigationController {
        context.coordinator.start()
        return context.coordinator.rootViewController
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
}
