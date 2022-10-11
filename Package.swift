// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "lytics",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "Lytics",
            targets: ["Lytics"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "Lytics",
            dependencies: []),
        .testTarget(
            name: "LyticsTests",
            dependencies: ["Lytics"]),
    ]
)
