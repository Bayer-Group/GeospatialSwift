// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "GeospatialSwift",
    products: [
        .library(
            name: "GeospatialSwift",
            targets:  ["GeospatialSwift"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "GeospatialSwift",
            dependencies: []
        ),
        .testTarget(
            name: "GeospatialSwiftTests",
            dependencies: ["GeospatialSwift"]
        )
    ]
)
