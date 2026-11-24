//
//  NetworkManager.swift
//
//
//  Created by Yasin Nazlican on 17.11.2021.
//

import Foundation

public protocol Requestable: Sendable {

    func sendRequest<T: Decodable & Sendable>(
        type: T.Type,
        target: any NetworkTarget
    ) async -> Result<T, AppError>
}

public struct NetworkManager: Requestable {

    // MARK: Private Variables

    private let session: URLSession
    private let requestTimeout: TimeInterval

    // MARK: Life-Cycle

    public init(session: URLSession = .shared, requestTimeout: TimeInterval = 60) {
        self.session = session
        self.requestTimeout = requestTimeout
    }

    // MARK: Public Methods

    public func sendRequest<T: Decodable & Sendable>(
        type: T.Type,
        target: any NetworkTarget
    ) async -> Result<T, AppError> {
        guard let request = makeRequest(from: target) else {
            return .failure(.unexpected("Invalid URL for path: \(target.path)"))
        }

        do {
            let (data, response) = try await session.data(for: request)
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            guard (200...299).contains(statusCode) else {
                return .failure(.api(.server))
            }
            return decode(type, from: data)
        } catch {
            return .failure(Self.appError(from: error))
        }
    }

    // MARK: Private Methods

    private func makeRequest(from target: any NetworkTarget) -> URLRequest? {
        var components = URLComponents(string: target.baseURL + target.path)
        components?.queryItems = target.queryItems.isEmpty ? nil : target.queryItems
        guard let url = components?.url else { return nil }

        var request = URLRequest(url: url, timeoutInterval: target.requestTimeout ?? requestTimeout)
        request.httpMethod = target.method.rawValue
        request.allHTTPHeaderFields = target.headers
        request.httpBody = target.body
        return request
    }

    private func decode<T: Decodable>(_ type: T.Type, from data: Data) -> Result<T, AppError> {
        guard let value = try? JSONDecoder().decode(type, from: data) else {
            return .failure(.api(.decoding))
        }
        return .success(value)
    }

    private static func appError(from error: any Error) -> AppError {
        if error is CancellationError { return .api(.cancelled) }
        guard let urlError = error as? URLError else { return .api(.server) }

        switch urlError.code {
        case .cancelled:
            return .api(.cancelled)
        case .timedOut:
            return .api(.timeout)
        case .notConnectedToInternet, .networkConnectionLost, .dataNotAllowed:
            return .api(.offline)
        default:
            return .api(.server)
        }
    }
}
