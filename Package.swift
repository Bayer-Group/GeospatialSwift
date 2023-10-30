// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "GeospatialSwift",
    products: [
        .library(name: "GeospatialSwift",targets:  ["GeospatialSwift"])
    ],
    dependencies: [
        .package(url: "https://github.com/GEOSwift/geos.git", from: "8.1.0")
    ],
    targets: [
        .target(
            name: "GeospatialSwift",
            dependencies: ["geos"]
        ),
        .testTarget(
            name: "GeospatialSwiftTests",
            dependencies: ["GeospatialSwift"]
        )
    ]
)
