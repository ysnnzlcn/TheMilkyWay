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
        target: NetworkTarget
    ) -> AnyPublisher<T, NetworkError> where T: Decodable
}

public final class NetworkManager: Requestable {

    // MARK: Shared

    public static let shared = NetworkManager()

    // MARK: Public Read-Only

    public var requestTimeout: Float { 60 }

    // MARK: Public Methods

    public func sendRequest<T: Decodable>(
        type: T.Type,
        target: NetworkTarget
    ) -> AnyPublisher<T, NetworkError> {

        URLSessionConfiguration.default.timeoutIntervalForRequest = TimeInterval(target.requestTimeout ?? requestTimeout)

        return URLSession.shared
            .dataTaskPublisher(for: makeRequest(from: target))
            .mapError { NetworkError.error($0) }
            .flatMap({ result -> AnyPublisher<T, NetworkError> in
                guard let urlResponse = result.response as? HTTPURLResponse,
                      (200...299).contains(urlResponse.statusCode) else {
                          return Just(result.data)
                              .decode(type: NetworkErrorResponse.self, decoder: JSONDecoder())
                              .tryMap({ errorModel in throw NetworkError.internalError(errorModel) })
                              .mapError { NetworkError.error($0) }
                              .eraseToAnyPublisher()
                      }
                return Just(result.data)
                    .decode(type: T.self, decoder: JSONDecoder())
                    .mapError { NetworkError.error($0) }
                    .eraseToAnyPublisher()
            })
            .eraseToAnyPublisher()
    }

    // MARK: Private Methods

    private func makeRequest(from target: NetworkTarget) -> URLRequest {
        var components = URLComponents(string: target.url.absoluteString)
        components?.queryItems = target.queryItems

        guard let url = components?.url else { fatalError("Please provide a valid path url.") }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = target.method.rawValue
        urlRequest.allHTTPHeaderFields = target.headers ?? [:]
        urlRequest.httpBody = target.body
        return urlRequest
    }
}
