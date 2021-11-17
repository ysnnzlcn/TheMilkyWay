//
//  NetworkManager.swift
//  
//
//  Created by Yasin Nazlican on 17.11.2021.
//

import Foundation
import Combine

public protocol Requestable: AnyObject {

    var requestTimeout: Float { get }

    func sendRequest<T>(
        type: T.Type,
        url: URL,
        target: NetworkTarget
    ) -> AnyPublisher<T, Error> where T: Decodable
}

public final class NetworkManager: Requestable {

    // MARK: Shared

    public static let shared = NetworkManager()

    // MARK: Public Read-Only

    public var requestTimeout: Float { 60 }

    // MARK: Public Methods

    public func sendRequest<T: Decodable>(
        type: T.Type,
        url: URL,
        target: NetworkTarget
    ) -> AnyPublisher<T, Error> {

        URLSessionConfiguration.default.timeoutIntervalForRequest = TimeInterval(target.requestTimeout ?? requestTimeout)

        return URLSession.shared
            .dataTaskPublisher(for: makeRequest(from: target))
            .tryMap { output in
                /// Throw an error if response is nil
                guard output.response is HTTPURLResponse else {
                    throw NetworkError.serverError(code: 0, error: "Server error")
                }
                return output.data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error in
                /// Return error if json decoding fails
                NetworkError.invalidJSON(String(describing: error))
            }
            .eraseToAnyPublisher()
    }

    // MARK: Private Methods

    private func makeRequest(from target: NetworkTarget) -> URLRequest {
        var urlRequest = URLRequest(url: target.path)
        urlRequest.httpMethod = target.method.rawValue
        urlRequest.allHTTPHeaderFields = target.headers ?? [:]
        urlRequest.httpBody = target.body
        return urlRequest
    }
}
