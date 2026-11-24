//
//  NetworkManager.swift
//  CoreAPIImpl
//
//  Created by Yasin Nazlican on 17.11.2021.
//

import CoreBase
import Foundation

protocol Requestable: Sendable {

    func sendRequest<T: Decodable & Sendable>(
        type: T.Type,
        target: any NetworkTarget
    ) async -> Result<T, AppError>
}

struct NetworkManager: Requestable {

    // MARK: Private Variables

    private let session: URLSession
    private let requestTimeout: TimeInterval

    // MARK: Life-Cycle

    init(session: URLSession = .shared, requestTimeout: TimeInterval = 60) {
        self.session = session
        self.requestTimeout = requestTimeout
    }

    // MARK: Methods

    func sendRequest<T: Decodable & Sendable>(
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
                Log.error("\(target.path) failed with status \(statusCode)", .api)
                return .failure(.network(.server))
            }
            return decode(type, from: data, path: target.path)
        } catch {
            let appError = Self.appError(from: error)
            // Cancelling is normal (a newer search replaced this one).
            if appError == .network(.cancelled) {
                Log.debug("\(target.path) cancelled", .api)
            } else {
                Log.warning("\(target.path) failed: \(appError)", .api)
            }
            return .failure(appError)
        }
    }

    // MARK: Private Methods

    private func makeRequest(from target: any NetworkTarget) -> URLRequest? {
        guard var components = URLComponents(string: target.baseURL + target.path) else { return nil }
        components.queryItems = target.queryItems.isEmpty ? nil : target.queryItems
        // URLComponents leaves "+" as is, and servers read it as a space.
        let query = components.percentEncodedQuery
        components.percentEncodedQuery = query?.replacingOccurrences(of: "+", with: "%2B")
        guard let url = components.url else { return nil }

        var request = URLRequest(url: url, timeoutInterval: target.requestTimeout ?? requestTimeout)
        request.httpMethod = target.method.rawValue
        return request
    }

    private func decode<T: Decodable>(_ type: T.Type, from data: Data, path: String) -> Result<T, AppError> {
        do {
            return .success(try JSONDecoder().decode(type, from: data))
        } catch {
            // Only the field path: the full error can quote the response.
            Log.error("\(path) decoding failed at \(Self.codingPath(of: error))", .api)
            return .failure(.network(.decoding))
        }
    }

    private static func codingPath(of error: any Error) -> String {
        let path: [any CodingKey] = switch error as? DecodingError {
        case .typeMismatch(_, let context), .valueNotFound(_, let context), .dataCorrupted(let context):
            context.codingPath
        case .keyNotFound(let key, let context):
            context.codingPath + [key]
        default:
            []
        }
        let text = path.map { $0.intValue.map(String.init) ?? $0.stringValue }.joined(separator: ".")
        return text.isEmpty ? "root" : text
    }

    private static func appError(from error: any Error) -> AppError {
        if error is CancellationError { return .network(.cancelled) }
        guard let urlError = error as? URLError else { return .network(.server) }

        switch urlError.code {
        case .cancelled:
            return .network(.cancelled)
        case .timedOut:
            return .network(.timeout)
        case .notConnectedToInternet, .networkConnectionLost, .dataNotAllowed:
            return .network(.offline)
        default:
            return .network(.server)
        }
    }
}
