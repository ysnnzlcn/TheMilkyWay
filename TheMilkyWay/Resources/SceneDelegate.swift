//
//  SceneDelegate.swift
//  TheMilkyWay
//
//  Created by Yasin Nazlican on 17.11.2021.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    public var window: UIWindow?
    public private(set) var appCoordinator: AppCoordinator!

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        setup(windowScene)
    }

    private func setup(_ windowScene: UIWindowScene) {
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        appCoordinator = AppCoordinator(window: window)
        appCoordinator.start()
    }
}
