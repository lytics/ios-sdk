// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "lytics",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "Lytics",
            targets: ["Lytics"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/Flight-School/AnyCodable",
            from: "0.6.6"
        ),
    ],
    targets: [
        .target(
            name: "Lytics",
            dependencies: [
                "AnyCodable"
            ]),
        .testTarget(
            name: "LyticsTests",
            dependencies: ["Lytics"]),
    ]
)
