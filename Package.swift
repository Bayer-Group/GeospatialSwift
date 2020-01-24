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
    dependencies: [
        .package(url: "https://github.com/MonsantoCo/TimberSwift.git", .upToNextMajor(from: "0.3.0"))
    ],
    targets: [
        .target(
            name: "GeospatialSwift",
            dependencies: ["TimberSwift"]
        ),
        .testTarget(
            name: "GeospatialSwiftTests",
            dependencies: ["GeospatialSwift"]
        )
    ]
)
