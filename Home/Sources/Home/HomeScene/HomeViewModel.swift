//
//  HomeViewModel.swift
//  
//
//  Created by Yasin Nazlican on 18.11.2021.
//

import Foundation
import Core

public final class HomeViewModel {

    // MARK: Private Variables

    private let service: NASAServices

    // MARK: Life-Cycle

    public init(service: NASAServices) {
        self.service = service
    }

    // MARK: Public Methods

    public func didLoad() { }
}
