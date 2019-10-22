import XCTest
@testable import CoordinateTransformationLibrary

final class CoordinateTransformationLibraryTests: XCTestCase {

    func testRT90ToWGS84() {
        let position = RT90Position (latitude: 6583052, longitude: 1627548)
        let wgsPos = position.toWGS84()

        // Values from Hitta.se for the conversion
        let latFromHitta = 59.3489
        let lonFromHitta = 18.0473

        let lat = round (wgsPos.latitude * 10000.0) / 10000.0
        let lon = round (wgsPos.longitude * 10000.0) / 10000.0

        XCTAssertEqual (latFromHitta, lat, accuracy: 0.00001)
        XCTAssertEqual (lonFromHitta, lon, accuracy: 0.00001)

        // String values from Lantmateriet.se, they convert DMS only.
        // Reference: https://www.lantmateriet.se/sv/Sjalvservice/enkel-koordinattransformation/
        let latDmsStringFromLM = "N 59º 20' 56.09287\""
        let lonDmsStringFromLM = "E 18º 2' 50.34806\""

        XCTAssertEqual (latDmsStringFromLM, wgsPos.latitudeToString (format: .degreesMinutesSeconds))
        XCTAssertEqual (lonDmsStringFromLM, wgsPos.longitudeToString (format: .degreesMinutesSeconds))
    }

    func testWGS84ToRT90() throws {
        let wgsPos = try WGS84Position (string: "N 59º 58' 55.23\" E 017º 50' 06.12\"", format: .degreesMinutesSeconds)
        let rtPos = RT90Position (wgs84: wgsPos, projection: .rt90_2_5_gon_v)

        // Conversion values from Lantmateriet.se, they convert from DMS only.
        // Reference: https://www.lantmateriet.se/sv/Sjalvservice/enkel-koordinattransformation/
        let xPosFromLM = 6653174.343
        let yPosFromLM = 1613318.742

        let lat = round (rtPos.latitude * 1000.0) / 1000.0
        let lon = round (rtPos.longitude * 1000.0) / 1000.0

        XCTAssertEqual (lat, xPosFromLM, accuracy: 0.0001)
        XCTAssertEqual (lon, yPosFromLM, accuracy: 0.0001)
    }

    func testWGS84ToSweref() throws {
        let wgsPos = try WGS84Position (string: "N 59º 58' 55.23\" E 017º 50' 06.12\"", format: .degreesMinutesSeconds)
        let rtPos = SWEREF99Position (wgs84: wgsPos, projection: .sweref_99_tm)

        // Conversion values from Lantmateriet.se, they convert from DMS only.
        // Reference: https://www.lantmateriet.se/sv/Sjalvservice/enkel-koordinattransformation/
        let xPosFromLM = 6652797.165
        let yPosFromLM = 658185.201

        let lat = round (rtPos.latitude * 1000.0) / 1000.0
        let lon = round (rtPos.longitude * 1000.0) / 1000.0

        XCTAssertEqual (lat, xPosFromLM, accuracy: 0.0001)
        XCTAssertEqual (lon, yPosFromLM, accuracy: 0.0001)
    }

    func testSwerefToWGS84() {
        let swePos = SWEREF99Position (latitude: 6652797.165, longitude: 658185.201)
        let wgsPos = swePos.toWGS84()

        // String values from Lantmateriet.se, they convert DMS only.
        // Reference: https://www.lantmateriet.se/sv/Sjalvservice/enkel-koordinattransformation/
        let latDmsStringFromLM = "N 59º 58' 55.23001\""
        let lonDmsStringFromLM = "E 17º 50' 6.11997\""

        XCTAssertEqual (latDmsStringFromLM, wgsPos.latitudeToString (format: .degreesMinutesSeconds))
        XCTAssertEqual (lonDmsStringFromLM, wgsPos.longitudeToString (format: .degreesMinutesSeconds))
    }

    func testWGS84Parse() throws {
        // Values from Eniro.se
        let wgsPosDM = try WGS84Position (string: "N 62º 10.560' E 015º 54.180'", format: .degreesMinutes)
        let wgsPosDMs = try WGS84Position (string: "N 62º 10' 33.60\" E 015º 54' 10.80\"", format: .degreesMinutesSeconds)

        let lat = round (wgsPosDM.latitude * 1000.0) / 1000.0
        let lon = round (wgsPosDM.longitude * 1000.0) / 1000.0

        XCTAssertEqual (62.176, lat, accuracy: 0.0001)
        XCTAssertEqual (15.903, lon, accuracy: 0.0001)

        let lat_s = round (wgsPosDMs.latitude * 1000.0) / 1000.0
        let lon_s = round (wgsPosDMs.longitude * 1000.0) / 1000.0

        XCTAssertEqual (62.176, lat_s, accuracy: 0.0001)
        XCTAssertEqual (15.903, lon_s, accuracy: 0.0001)
    }
}
