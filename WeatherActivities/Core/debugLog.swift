//
//  debugLog.swift
//  WeatherActivities
//
//  Created by Nitin George on 14/11/2026.
//

nonisolated func debugLog(
    _ message: @autoclosure () -> String
) {
    #if DEBUG
    print(message())
    #endif
}
