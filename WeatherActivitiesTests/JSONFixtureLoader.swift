//
//  JSONFixtureLoader.swift
//  WeatherActivities
//
//  Created by Nitin George on 14/11/2026.
//

import Foundation

enum JSONFixtureLoader {

    enum FixtureError: Error {
        case fileNotFound(String)
    }

    static func load(
        _ name: String,
        bundle: Bundle
    ) throws -> Data {

        guard let url = bundle.url(
            forResource: name,
            withExtension: "json"
        ) else {
            throw FixtureError.fileNotFound(name)
        }

        return try Data(contentsOf: url)
    }
}
