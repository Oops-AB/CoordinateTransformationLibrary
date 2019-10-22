//
//  GaussKreuger.swift
//  
//
//  Created by Johan Carlberg on 2019-10-21.
//

import Foundation

struct GaussKreuger {

    /**
     * Semi-major axis of the ellipsoid.
     */
    let axis: Double
    
    /**
     * Flattening of the ellipsoid.
     */
    let flattening: Double
    
    /**
     * Central meridian for the projection.
     */
    let centralMeridian: Double
    
    /**
     * Scale on central meridian.
     */
    let scale: Double
    
    /**
     * Offset for origo.
     */
    let falseNorthing: Double
    
    /**
     * Offset for origo.
     */
    let falseEasting: Double

    init (rt90 projection: RT90Position.RT90Projection) {
        axis = 6378137.0; // GRS 80.
        flattening = 1.0 / 298.257222101; // GRS 80.

        switch projection {
            case .rt90_7_5_gon_v:
                centralMeridian = 11.0 + 18.375 / 60.0
                scale = 1.000006000000
                falseNorthing = -667.282
                falseEasting = 1500025.141

            case .rt90_5_0_gon_v:
                centralMeridian = 13.0 + 33.376 / 60.0
                scale = 1.000005800000
                falseNorthing = -667.130
                falseEasting = 1500044.695

            case .rt90_2_5_gon_v:
                centralMeridian = 15.0 + 48.0 / 60.0 + 22.624306 / 3600.0
                scale = 1.00000561024
                falseNorthing = -667.711
                falseEasting = 1500064.274

            case .rt90_0_0_gon_v:
                centralMeridian = 18.0 + 3.378 / 60.0
                scale = 1.000005400000
                falseNorthing = -668.844
                falseEasting = 1500083.521

            case .rt90_2_5_gon_o:
                centralMeridian = 20.0 + 18.379 / 60.0
                scale = 1.000005200000
                falseNorthing = -670.706
                falseEasting = 1500102.765

            case .rt90_5_0_gon_o:
                centralMeridian = 22.0 + 33.380 / 60.0
                scale = 1.000004900000
                falseNorthing = -672.557
                falseEasting = 1500121.846
        }
    }

    init (sweref99 projection: SWEREF99Position.SWEREF99Projection) {
        axis = 6378137.0; // GRS 80.
        flattening = 1.0 / 298.257222101; // GRS 80.

        switch projection {
            case .sweref_99_tm:
                centralMeridian = 15.00
                scale = 0.9996
                falseNorthing = 0.0
                falseEasting = 500000.0

            case .sweref_99_12_00:
                centralMeridian = 12.00
                scale = 1.0
                falseNorthing = 0.0
                falseEasting = 150000.0

            case .sweref_99_13_30:
                centralMeridian = 13.50
                scale = 1.0
                falseNorthing = 0.0
                falseEasting = 150000.0

            case .sweref_99_15_00:
                centralMeridian = 15.00
                scale = 1.0
                falseNorthing = 0.0
                falseEasting = 150000.0

            case .sweref_99_16_30:
                centralMeridian = 16.50
                scale = 1.0
                falseNorthing = 0.0
                falseEasting = 150000.0

            case .sweref_99_18_00:
                centralMeridian = 18.00
                scale = 1.0
                falseNorthing = 0.0
                falseEasting = 150000.0

            case .sweref_99_14_15:
                centralMeridian = 14.25
                scale = 1.0
                falseNorthing = 0.0
                falseEasting = 150000.0

            case .sweref_99_15_45:
                centralMeridian = 15.75
                scale = 1.0
                falseNorthing = 0.0
                falseEasting = 150000.0

            case .sweref_99_17_15:
                centralMeridian = 17.25
                scale = 1.0
                falseNorthing = 0.0
                falseEasting = 150000.0

            case .sweref_99_18_45:
                centralMeridian = 18.75
                scale = 1.0
                falseNorthing = 0.0
                falseEasting = 150000.0

            case .sweref_99_20_15:
                centralMeridian = 20.25
                scale = 1.0
                falseNorthing = 0.0
                falseEasting = 150000.0

            case .sweref_99_21_45:
                centralMeridian = 21.75
                scale = 1.0
                falseNorthing = 0.0
                falseEasting = 150000.0

            case .sweref_99_23_15:
                centralMeridian = 23.25
                scale = 1.0
                falseNorthing = 0.0
                falseEasting = 150000.0
        }
    }

    func geodeticToGrid (latitude: Double, longitude: Double) -> (Double, Double) {
        // Prepare ellipsoid-based stuff.
        let e2: Double = flattening * (2.0 - flattening)
        let n: Double = flattening / (2.0 - flattening)
        let a_roof: Double = axis / (1.0 + n) * (1.0 + n * n / 4.0 + n * n * n * n / 64.0)
        let A: Double = e2
        let B: Double = (5.0 * e2 * e2 - e2 * e2 * e2) / 6.0
        let C: Double = (104.0 * e2 * e2 * e2 - 45.0 * e2 * e2 * e2 * e2) / 120.0
        let D: Double = (1237.0 * e2 * e2 * e2 * e2) / 1260.0
        let beta1: Double = n / 2.0 - 2.0 * n * n / 3.0 + 5.0 * n * n * n / 16.0 + 41.0 * n * n * n * n / 180.0
        let beta2: Double = 13.0 * n * n / 48.0 - 3.0 * n * n * n / 5.0 + 557.0 * n * n * n * n / 1440.0
        let beta3: Double = 61.0 * n * n * n / 240.0 - 103.0 * n * n * n * n / 140.0
        let beta4: Double = 49561.0 * n * n * n * n / 161280.0

        // Convert.
        let deg_to_rad = Double.pi / 180.0
        let phi = latitude * deg_to_rad
        let lambda = longitude * deg_to_rad
        let lambda_zero = centralMeridian * deg_to_rad

        let phi_star = phi - sin (phi) * cos (phi) * (A +
            B * pow (sin (phi), 2) +
            C * pow (sin (phi), 4) +
            D * pow (sin (phi), 6))
        let delta_lambda = lambda - lambda_zero
        let xi_prim = atan (tan (phi_star) / cos (delta_lambda))
        let eta_prim = atanh (cos (phi_star) * sin (delta_lambda))
        let x = scale * a_roof * (xi_prim +
                beta1 * sin (2.0 * xi_prim) * cosh (2.0 * eta_prim) +
                beta2 * sin (4.0 * xi_prim) * cosh (4.0 * eta_prim) +
                beta3 * sin (6.0 * xi_prim) * cosh (6.0 * eta_prim) +
                beta4 * sin (8.0 * xi_prim) * cosh (8.0 * eta_prim)) +
                falseNorthing
        let y = scale * a_roof * (eta_prim +
                beta1 * cos (2.0 * xi_prim) * sinh (2.0 * eta_prim) +
                beta2 * cos (4.0 * xi_prim) * sinh (4.0 * eta_prim) +
                beta3 * cos (6.0 * xi_prim) * sinh (6.0 * eta_prim) +
                beta4 * cos (8.0 * xi_prim) * sinh (8.0 * eta_prim)) +
                falseEasting

        return (round (x * 1000.0) / 1000.0, round (y * 1000.0) / 1000.0)
    }

    // Conversion from grid coordinates to geodetic coordinates.
    func gridToGeodetic (x: Double, y: Double) -> (Double, Double) {
        if centralMeridian == Double.leastNormalMagnitude {
            return (x, y)
        }
        // Prepare ellipsoid-based stuff.
        let e2: Double = flattening * (2.0 - flattening)
        let n: Double = flattening / (2.0 - flattening)
        let a_roof: Double = axis / (1.0 + n) * (1.0 + n * n / 4.0 + n * n * n * n / 64.0)
        let delta1: Double = n / 2.0 - 2.0 * n * n / 3.0 + 37.0 * n * n * n / 96.0 - n * n * n * n / 360.0
        let delta2: Double = n * n / 48.0 + n * n * n / 15.0 - 437.0 * n * n * n * n / 1440.0
        let delta3: Double = 17.0 * n * n * n / 480.0 - 37 * n * n * n * n / 840.0
        let delta4: Double = 4397.0 * n * n * n * n / 161280.0

        let Astar: Double = e2 + e2 * e2 + e2 * e2 * e2 + e2 * e2 * e2 * e2
        let Bstar: Double = -(7.0 * e2 * e2 + 17.0 * e2 * e2 * e2 + 30.0 * e2 * e2 * e2 * e2) / 6.0
        let Cstar: Double = (224.0 * e2 * e2 * e2 + 889.0 * e2 * e2 * e2 * e2) / 120.0
        let Dstar: Double = -(4279.0 * e2 * e2 * e2 * e2) / 1260.0

        // Convert.
        let deg_to_rad = Double.pi / 180
        let lambda_zero = centralMeridian * deg_to_rad
        let xi = (x - falseNorthing) / (scale * a_roof)
        let eta = (y - falseEasting) / (scale * a_roof)
        let xi_prim = xi -
                delta1 * sin (2.0 * xi) * cosh (2.0 * eta) -
                delta2 * sin (4.0 * xi) * cosh (4.0 * eta) -
                delta3 * sin (6.0 * xi) * cosh (6.0 * eta) -
                delta4 * sin (8.0 * xi) * cosh (8.0 * eta)
        let eta_prim = eta -
                delta1 * cos (2.0 * xi) * sinh (2.0 * eta) -
                delta2 * cos (4.0 * xi) * sinh (4.0 * eta) -
                delta3 * cos (6.0 * xi) * sinh (6.0 * eta) -
                delta4 * cos (8.0 * xi) * sinh (8.0 * eta)
        let phi_star = asin (sin (xi_prim) / cosh (eta_prim))
        let delta_lambda = atan (sinh (eta_prim) / cos (xi_prim))
        let lon_radian = lambda_zero + delta_lambda
        let lat_radian = phi_star + sin (phi_star) * cos (phi_star) *
                (Astar +
                Bstar * pow (sin (phi_star), 2) +
                Cstar * pow (sin (phi_star), 4) +
                Dstar * pow (sin (phi_star), 6))

        return (lat_radian * 180.0 / Double.pi, lon_radian * 180.0 / Double.pi)
    }
}
