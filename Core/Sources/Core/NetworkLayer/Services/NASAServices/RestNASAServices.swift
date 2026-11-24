//
//  RestNASAServices.swift
//
//
//  Created by Yasin Nazlican on 17.11.2021.
//

import Foundation

public struct RestNASAServices: NASAServices {

    // MARK: Private Variables

    private let networkManager: any Requestable

    // MARK: Life-Cycle

    public init(networkManager: any Requestable = NetworkManager()) {
        self.networkManager = networkManager
    }

    // MARK: Protocol Conformance

    public func searchImages() async -> Result<NASAImageResponse, AppError> {
        /// "" means search for all.
        await networkManager.sendRequest(
            type: NASAImageResponse.self,
            target: NASANetworkTarget.searchImages(key: "\"\"")
        )
    }
}
