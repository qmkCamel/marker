// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "MarkerData",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "MarkerData",
            targets: ["MarkerData"]
        )
    ],
    dependencies: [
        .package(path: "../MarkerDomain"),
        .package(url: "https://github.com/groue/GRDB.swift.git", from: "7.10.0"),
    ],
    targets: [
        .target(
            name: "MarkerData",
            dependencies: [
                .product(name: "MarkerDomain", package: "MarkerDomain"),
                .product(name: "GRDB", package: "GRDB.swift")
            ]
        ),
        .testTarget(
            name: "MarkerDataTests",
            dependencies: ["MarkerData"]
        )
    ]
)
