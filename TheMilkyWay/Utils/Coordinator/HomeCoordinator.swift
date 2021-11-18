//
//  HomeCoordinator.swift
//  
//
//  Created by Yasin Nazlican on 18.11.2021.
//

import Core
import Home
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

    public override func start() {
        let homeViewController = makeController(type: .home)
        rootViewController.setViewControllers([homeViewController], animated: false)
    }

    private func makeController(type: HomeControllers) -> UIViewController {
        switch type {
        case .home:
            let viewModel = HomeViewModel(service: RestNASAServices())
            let controller = HomeViewController(viewModel: viewModel)
            return controller
        }
    }
}
