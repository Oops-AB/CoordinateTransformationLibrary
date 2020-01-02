//
//  SWEREF99Position.swift
//  
//
//  Created by Johan Carlberg on 2019-10-21.
//

public struct SWEREF99Position: Position {
    public enum SWEREF99Projection {
        case sweref_99_tm
        case sweref_99_12_00
        case sweref_99_13_30
        case sweref_99_15_00
        case sweref_99_16_30
        case sweref_99_18_00
        case sweref_99_14_15
        case sweref_99_15_45
        case sweref_99_17_15
        case sweref_99_18_45
        case sweref_99_20_15
        case sweref_99_21_45
        case sweref_99_23_15
    }

    public let latitude: Double
    public let longitude: Double
    let gridFormat = Grid.SWEREF99
    private let projection: SWEREF99Projection

    public var n: Double {
        return latitude
    }
    public var e: Double {
        return longitude
    }

    public init (n: Double, e: Double, projection: SWEREF99Projection) {
        self.latitude = n
        self.longitude = e
        self.projection = projection
    }

    public init (latitude: Double, longitude: Double) {
        self.init (n: latitude, e: longitude, projection: .sweref_99_tm)
    }

    public init (wgs84 position: WGS84Position, projection: SWEREF99Projection) {
        let gkProjection = GaussKreuger (sweref99: projection)
        let (n, e) = gkProjection.geodeticToGrid (latitude: position.latitude, longitude: position.longitude)

        self.init (n: n, e: e, projection: projection)
    }

    public func toWGS84() -> WGS84Position {
        let gkProjection = GaussKreuger (sweref99: projection)
        let (latitude, longitude) = gkProjection.gridToGeodetic (x: self.latitude, y: self.longitude)
        let newPosition = WGS84Position (latitude: latitude, longitude: longitude)

        return newPosition
    }
}

extension SWEREF99Position: CustomStringConvertible {
    public var description: String {
        return String (describing: projection).withCString { projection in
            return String (format: "N: %f E: %f Projection: %s", self.latitude, self.longitude, projection)
        }
    }
}
