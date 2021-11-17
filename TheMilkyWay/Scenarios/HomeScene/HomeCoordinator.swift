//
//  HomeCoordinator.swift
//  TheMilkyWay
//
//  Created by Yasin Nazlican on 17.11.2021.
//

import UIKit

fileprivate enum HomeControllers {

    case home
}

public final class HomeCoordinator: Coordinator {

    // MARK: Properties

    public let rootViewController: UINavigationController

    // MARK: Life-Cycle

    public init(rootViewController: UINavigationController) {
        self.rootViewController = rootViewController
    }

    public override func start() { }

    private func push(_ controller: UIViewController) {
        rootViewController.pushViewController(controller, animated: true)
    }
}
