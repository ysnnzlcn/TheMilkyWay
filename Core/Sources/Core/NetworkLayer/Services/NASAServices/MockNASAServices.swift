//
//  MockNASAServices.swift
//  
//
//  Created by Yasin Nazlican on 17.11.2021.
//

import Combine
import Foundation

public class MockNASAServices: NASAServices {

    // MARK: Public Variables
    public var getCallsCount: Int = 0
    public var getResult: Result<NASAImageResponse, NetworkError> = .failure(NetworkError.mock())

    // MARK: Life-Cycle

    public init() { }

    // MARK: Protocol Conformance

    public func searchImages() -> AnyPublisher<NASAImageResponse, NetworkError> {
        getCallsCount += 1
        return getResult.publisher.eraseToAnyPublisher()
    }
}
