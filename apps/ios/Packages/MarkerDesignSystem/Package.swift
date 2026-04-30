// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "MarkerDesignSystem",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "MarkerDesignSystem",
            targets: ["MarkerDesignSystem"]
        )
    ],
    targets: [
        .target(
            name: "MarkerDesignSystem"
        ),
        .testTarget(
            name: "MarkerDesignSystemTests",
            dependencies: ["MarkerDesignSystem"]
        )
    ]
)
