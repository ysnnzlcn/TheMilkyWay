//
//  MockNASAServices.swift
//  
//
//  Created by Yasin Nazlican on 17.11.2021.
//

import Foundation
import Combine

public struct MockNASAServices: NASAServices {

    // MARK: Protocol Conformance

    public func searchImages() -> AnyPublisher<NASAImageResponse, NetworkError> {
        return Empty(completeImmediately: false).eraseToAnyPublisher() /// Will be updated.
    }
}
