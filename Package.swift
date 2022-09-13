// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ios-sdk",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "ios-sdk",
            targets: ["ios-sdk"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "ios-sdk",
            dependencies: []),
        .testTarget(
            name: "ios-sdkTests",
            dependencies: ["ios-sdk"]),
    ]
)
