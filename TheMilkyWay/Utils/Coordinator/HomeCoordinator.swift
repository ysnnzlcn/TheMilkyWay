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
    case imageDetail(_ image: NASAImage)
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
            controller.delegate = self
            return controller

        case .imageDetail(let image):
            return UIViewController()
        }
    }

    private func navigateTo(type: HomeControllers) {
        let controller = makeController(type: type)
        rootViewController.pushViewController(controller, animated: true)
    }
}

extension HomeCoordinator: HomeViewControllerCoordinatorDelegate {

    public func homeViewControllerDidSelect(_ sender: HomeViewController, image: NASAImage) {
        navigateTo(type: .imageDetail(image))
    }
}
