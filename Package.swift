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
        .library(
            name: "LyticsUI",
            targets: ["LyticsUI"])
    ],
    dependencies: [
        .package(
            url: "https://github.com/Flight-School/AnyCodable",
            from: "0.6.6"),
        .package(
            url: "https://github.com/mobelux/swift-version-file-plugin",
            from: "0.1.0")
    ],
    targets: [
        .target(
            name: "Lytics",
            dependencies: [
                "AnyCodable"
            ]),
        .target(
            name: "LyticsUI",
            dependencies: [
                "Lytics"
            ]),
        .testTarget(
            name: "LyticsTests",
            dependencies: ["Lytics"])
    ]
)
