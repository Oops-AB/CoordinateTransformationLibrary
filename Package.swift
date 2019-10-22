// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "CoordinateTransformationLibrary",
    products: [
        .library(
            name: "CoordinateTransformationLibrary",
            targets: ["CoordinateTransformationLibrary"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "CoordinateTransformationLibrary",
            dependencies: []),
        .testTarget(
            name: "CoordinateTransformationLibraryTests",
            dependencies: ["CoordinateTransformationLibrary"]),
    ]
)
