//
//  AppCoordinator.swift
//  TheMilkyWay
//
//  Created by Yasin Nazlican on 17.11.2021.
//

import Core
import CoreUI
import UIKit

public final class AppCoordinator: Coordinator {

    // MARK: Public Properties

    public let service: NASAServices
    public private(set) lazy var rootViewController = UINavigationController()

    // MARK: Life-Cycle

    public init(service: NASAServices) {
        self.service = service
    }

    public override func start() {
        UINavigationBar.applyDefaultStyling()
        let homeCoordinator = HomeCoordinator(
            rootViewController: rootViewController,
            service: service
        )
        addChildCoordinator(homeCoordinator)
        homeCoordinator.start()
    }
}
