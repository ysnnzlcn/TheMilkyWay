//
//  RestNASAServices.swift
//  
//
//  Created by Yasin Nazlican on 17.11.2021.
//

import Foundation
import Combine

public struct RestNASAServices: NASAServices {

    // MARK: Private Variables

    private let networkManager: NetworkManager

    // MARK: Life-Cycle

    public init(networkManager: NetworkManager = .shared) {
        self.networkManager = networkManager
    }

    // MARK: Protocol Conformance

    public func searchImages(with text: String) -> AnyPublisher<[NASAImage], NetworkError> {
        return Empty(completeImmediately: false).eraseToAnyPublisher() /// Will be updated.
    }
}
