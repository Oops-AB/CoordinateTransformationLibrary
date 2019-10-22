//
//  RT90Position.swift
//  
//
//  Created by Johan Carlberg on 2019-10-21.
//

public struct RT90Position: Position {
    public enum RT90Projection {
        case rt90_7_5_gon_v
        case rt90_5_0_gon_v
        case rt90_2_5_gon_v
        case rt90_0_0_gon_v
        case rt90_2_5_gon_o
        case rt90_5_0_gon_o
    }

    let latitude: Double
    let longitude: Double
    let gridFormat = Grid.RT90
    private let projection: RT90Projection

    public var x: Double {
        return latitude
    }
    public var y: Double {
        return longitude
    }

    init (x: Double, y: Double, projection: RT90Projection) {
        self.latitude = x
        self.longitude = y
        self.projection = projection
    }

    public init (latitude: Double, longitude: Double) {
        self.init (x: latitude, y: longitude, projection: .rt90_2_5_gon_v)
    }

    public init (wgs84 position: WGS84Position, projection: RT90Projection) {
        let gkProjection = GaussKreuger (rt90: projection)
        let (x, y) = gkProjection.geodeticToGrid (latitude: position.latitude, longitude: position.longitude)

        self.init (x: x, y: y, projection: projection)
    }

    public func toWGS84() -> WGS84Position {
        let gkProjection = GaussKreuger (rt90: projection)
        let (latitude, longitude) = gkProjection.gridToGeodetic (x: self.latitude, y: self.longitude)
        let newPosition = WGS84Position (latitude: latitude, longitude: longitude)

        return newPosition
    }
}

extension RT90Position: CustomStringConvertible {

    public var description: String {
        return String (format: "X: %f Y: %f Projection: %s", self.latitude, self.longitude, String (describing: projection))
    }
}
