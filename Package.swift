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
        .package(url: "https://github.com/MonsantoCo/TimberSwift.git", .branch("swift-5.1"))
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
