//
//  Position.swift
//  
//
//  Created by Johan Carlberg on 2019-10-21.
//

enum Grid {
    case RT90
    case WGS84
    case SWEREF99
}

protocol Position {

    var latitude: Double { get }
    var longitude: Double { get }
    var gridFormat: Grid { get }

    init (latitude: Double, longitude: Double)
    func toWGS84() -> WGS84Position
}
