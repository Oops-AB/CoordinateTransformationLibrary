//
//  WGS84Position.swift
//  
//
//  Created by Johan Carlberg on 2019-10-21.
//

import Foundation

public struct WGS84Position: Position {

    public enum WGS84Projection {
        case rt90_7_5_gon_v
        case rt90_5_0_gon_v
        case rt90_2_5_gon_v
        case rt90_0_0_gon_v
        case rt90_2_5_gon_o
        case rt90_5_0_gon_o
    }

    public enum WGS84Format {
        case degrees
        case degreesMinutes
        case degreesMinutesSeconds
    }

    struct ParseError: Error {}

    public let latitude: Double
    public let longitude: Double
    let gridFormat = Grid.WGS84
    
    public init (latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }

    public init (wgs84 position: WGS84Position) {
        self.latitude = position.latitude
        self.longitude = position.longitude
    }

    public func toWGS84() -> WGS84Position {
        return self
    }
}

extension WGS84Position {

    public init (string positionString: String, format: WGS84Format) throws {
        switch format {
            case .degrees:
                let latLon = positionString.trimmingCharacters (in: .whitespaces).split (separator: " ")

                guard latLon.count == 2 else {
                    throw ParseError()
                }
                guard let latitude = Double (latLon[0].replacingOccurrences (of: ",", with: ".")),
                    let longitude = Double (latLon[1].replacingOccurrences (of: ",", with: ".")) else {
                    throw ParseError()
                }

                self.latitude = latitude
                self.longitude = longitude

            case .degreesMinutes:
                guard let firstValueEndPos = positionString.firstIndex (of: "'") else {
                    throw ParseError()
                }

                let lat = positionString[ positionString.startIndex...firstValueEndPos ].trimmingCharacters (in: .whitespaces)
                let lon = positionString[ positionString.index (after: firstValueEndPos)...].trimmingCharacters (in: .whitespaces)

                self.latitude = try WGS84Position.latitudeFromString (lat, format: format)
                self.longitude = try WGS84Position.longitudeFromString (lon, format: format)

            case .degreesMinutesSeconds:
                guard let firstValueEndPos = positionString.firstIndex (of: "\"") else {
                    throw ParseError()
                }
                let secondValueStartPos = positionString.index (after: firstValueEndPos)

                let lat = positionString[ positionString.startIndex...firstValueEndPos ].trimmingCharacters (in: .whitespaces)
                let lon = positionString[ secondValueStartPos... ].trimmingCharacters (in: .whitespaces)

                self.latitude = try WGS84Position.latitudeFromString (lat, format: format)
                self.longitude = try WGS84Position.longitudeFromString (lon, format: format)
        }
    }

    private static func latitudeFromString (_ value: String, format: WGS84Format) throws -> Double {
        return try coordinateFromString (value, format: format, negative: "S")
    }

    private static func longitudeFromString (_ value: String, format: WGS84Format) throws -> Double {
        return try coordinateFromString (value, format: format, negative: "W")
    }

    private static func coordinateFromString (_ value: String, format: WGS84Format, negative: String) throws -> Double {
        switch format {
            case .degreesMinutes:
                return try coordinate (degreesMinutes: value.trimmingCharacters (in: .whitespaces), negative: negative)

            case .degreesMinutesSeconds:
                return try coordinate (degreesMinutesSeconds: value.trimmingCharacters (in: .whitespaces), negative: negative)

            case .degrees:
                guard let coordinate = Double (value) else {
                    throw ParseError()
                }

                return coordinate
            }
    }

    private static func coordinate (degreesMinutes: String, negative: String) throws -> Double {
        var value = degreesMinutes.prefix (Int.max)

        guard !value.isEmpty else {
            throw WGS84Position.ParseError()
        }

        let direction = value.prefix (1)
        value = value.dropFirst().trimmingCharacters (in: .whitespaces).prefix (Int.max)

        guard let degreeIndex = value.firstIndex (of: "º") else {
            throw WGS84Position.ParseError()
        }
        let degree = value[ ..<degreeIndex ]
        value = value[ value.index (after: degreeIndex)... ].trimmingCharacters (in: .whitespaces).prefix (Int.max)

        guard let minutesIndex = value.firstIndex (of: "'") else {
            throw WGS84Position.ParseError()
        }
        let minutes = value[ ..<minutesIndex ]

        guard let degreeValue = Double (degree),
            let minutesValue = Double (minutes.replacingOccurrences (of: ",", with: ".")) else {
                throw WGS84Position.ParseError()
        }

        let coordinate = degreeValue + minutesValue / 60.0
        guard coordinate <= 90.0 else {
            throw WGS84Position.ParseError()
        }

        if (direction == negative) || (direction == "-") {
            return -coordinate
        } else {
            return coordinate
        }
    }

    private static func coordinate (degreesMinutesSeconds: String, negative: String) throws -> Double {
        var value = degreesMinutesSeconds.prefix (Int.max)

        guard !value.isEmpty else {
            throw WGS84Position.ParseError()
        }

        let direction = value.prefix (1)
        value = value.dropFirst().trimmingCharacters (in: .whitespaces).prefix (Int.max)

        guard let degreeIndex = value.firstIndex (of: "º") else {
            throw WGS84Position.ParseError()
        }
        let degree = value[ ..<degreeIndex ]
        value = value[ value.index (after: degreeIndex)... ].trimmingCharacters (in: .whitespaces).prefix (Int.max)

        guard let minutesIndex = value.firstIndex (of: "'") else {
            throw WGS84Position.ParseError()
        }
        let minutes = value[ ..<minutesIndex ]
        value = value[ value.index (after: minutesIndex)... ].trimmingCharacters (in: .whitespaces).prefix (Int.max)

        guard let secondsIndex = value.firstIndex (of: "\"") else {
            throw WGS84Position.ParseError()
        }
        let seconds = value[ ..<secondsIndex ]

        guard let degreeValue = Double (degree),
            let minutesValue = Double (minutes.replacingOccurrences (of: ",", with: ".")),
            let secondsValue = Double (seconds.replacingOccurrences (of: ",", with: ".")) else {
                throw WGS84Position.ParseError()
        }

        let coordinate = degreeValue + minutesValue / 60.0 + secondsValue / 3600.0
        guard coordinate <= 90.0 else {
            throw WGS84Position.ParseError()
        }

        if (direction == negative) || (direction == "-") {
            return -coordinate
        } else {
            return coordinate
        }
    }
}

extension WGS84Position : CustomStringConvertible {
    public func latitudeToString (format: WGS84Format) -> String {
        switch format {
            case .degreesMinutes:
                return convertToDegreesMinutes (self.latitude, "N", "S")

            case .degreesMinutesSeconds:
                return convertToDegreesMinutesSeconds (self.latitude, "N", "S")

            default:
                return String (format: "%.10f", self.latitude)
        }
    }

    public func longitudeToString (format: WGS84Format) -> String {
        switch format {
            case .degreesMinutes:
                return convertToDegreesMinutes (self.longitude, "E", "W")

            case .degreesMinutesSeconds:
                return convertToDegreesMinutesSeconds (self.longitude, "E", "W")

            default:
                return String (format: "%.10f", self.longitude)
        }
    }

    private func convertToDegreesMinutes (_ value: Double, _ positiveValue: String, _ negativeValue: String) -> String {
        if value == Double.leastNormalMagnitude {
            return ""
        }
        let degrees = floor (abs (value))
        let minutes = (abs (value) - degrees) * 60.0

        return (value >= 0 ? positiveValue : negativeValue).withCString { prefix in
            return String (format: "%s %.0fº %.0f'", prefix, degrees, (floor (minutes * 10000.0) / 10000.0))
        }
    }

    private func convertToDegreesMinutesSeconds (_ value: Double, _ positiveValue: String, _ negativeValue: String) -> String {
        if value == Double.leastNormalMagnitude {
            return ""
        }
        let degrees = floor (abs (value))
        let minutes = floor ((abs (value) - degrees) * 60.0)
        let seconds = (abs (value) - degrees - minutes / 60.0) * 3600.0

        return (value >= 0 ? positiveValue : negativeValue).withCString { prefix in
            return String (format: "%s %.0fº %.0f' %.5f\"", prefix, degrees, minutes, (round (seconds * 100000.0) / 100000.0))
        }
    }

    public var description: String {
        return "Latitude: \(latitudeToString (format: .degreesMinutesSeconds)),  Longitude: \(longitudeToString (format: .degreesMinutesSeconds))"
    }
}
