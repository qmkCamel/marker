// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "MarkerDomain",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "MarkerDomain",
            targets: ["MarkerDomain"]
        )
    ],
    targets: [
        .target(
            name: "MarkerDomain"
        ),
        .testTarget(
            name: "MarkerDomainTests",
            dependencies: ["MarkerDomain"]
        )
    ]
)
