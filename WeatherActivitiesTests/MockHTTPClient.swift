//
//  MockHTTPClient.swift
//  WeatherActivities
//
//  Created by Nitin George on 14/11/2026.
//

import Foundation
import XCTest
@testable import WeatherActivities

struct MockHTTPClient: HTTPClientProtocol {

    let data: Data

    func get(url: URL) async throws -> Data {
        data
    }
}
