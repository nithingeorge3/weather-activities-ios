//
//  HTTPClient.swift
//  WeatherActivities
//
//  Created by Nitin George on 14/11/2026.
//

import Foundation

protocol HTTPClientProtocol: Sendable {
    func get(url: URL) async throws -> Data
}

enum HTTPClientError: LocalizedError {
    case invalidResponse
    case httpStatus(Int)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Unable to read the server response."

        case .httpStatus:
            return "The weather service is unavailable. Please try again."
        }
    }
}

struct URLSessionHTTPClient: HTTPClientProtocol {

    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func get(url: URL) async throws -> Data {
        let (data, response) = try await session.data(from: url)

        guard let response = response as? HTTPURLResponse else {
            throw HTTPClientError.invalidResponse
        }

        guard (200...299).contains(response.statusCode) else {
            throw HTTPClientError.httpStatus(response.statusCode)
        }

        return data
    }
}
