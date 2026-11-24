//
//  AppCoordinator.swift
//  TheMilkyWay
//
//  Created by Yasin Nazlican on 17.11.2021.
//

import CoreAPI
import CoreUI
import UIKit

public final class AppCoordinator: Coordinator {

    // MARK: Public Properties

    public let imageSearchApi: any ImageSearchApi
    public private(set) lazy var rootViewController = UINavigationController()

    // MARK: Life-Cycle

    public init(imageSearchApi: any ImageSearchApi) {
        self.imageSearchApi = imageSearchApi
    }

    public override func start() {
        UINavigationBar.applyDefaultStyling()
        let homeCoordinator = HomeCoordinator(
            rootViewController: rootViewController,
            imageSearchApi: imageSearchApi
        )
        addChildCoordinator(homeCoordinator)
        homeCoordinator.start()
    }
}
