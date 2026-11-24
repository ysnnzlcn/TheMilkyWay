//
//  HomeCoordinator.swift
//  
//
//  Created by Yasin Nazlican on 18.11.2021.
//

import CoreAPI
import CoreBase
import Home
import UIKit

fileprivate enum HomeControllers {

    case home
    case imageDetail(_ image: NASAImageDTO)
}

public final class HomeCoordinator: Coordinator {

    // MARK: Public Variables

    public let rootViewController: UINavigationController
    public let imageSearchApi: any ImageSearchApi

    // MARK: Life-Cycle

    public init(rootViewController: UINavigationController, imageSearchApi: any ImageSearchApi) {
        self.rootViewController = rootViewController
        self.imageSearchApi = imageSearchApi
    }

    public override func start() {
        let homeViewController = makeController(type: .home)
        rootViewController.setViewControllers([homeViewController], animated: false)
    }

    private func makeController(type: HomeControllers) -> UIViewController {
        switch type {
        case .home:
            let viewModel = HomeViewModel(imageSearchApi: imageSearchApi)
            let controller = HomeViewController(viewModel: viewModel)
            controller.delegate = self
            return controller

        case .imageDetail(let image):
            let viewModel = ImageDetailsViewModel(imageModel: image)
            let controller = ImageDetailsViewController(viewModel: viewModel)
            return controller
        }
    }

    private func navigateTo(type: HomeControllers) {
        let controller = makeController(type: type)
        rootViewController.pushViewController(controller, animated: true)
    }
}

extension HomeCoordinator: HomeViewControllerCoordinatorDelegate {

    public func homeViewControllerDidSelect(_ sender: HomeViewController, image: NASAImageDTO) {
        navigateTo(type: .imageDetail(image))
    }
}
