// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

enum EnvironmentKey {
    static let buildingDocs = "BUILDING_FOR_DOCUMENTATION_GENERATION"
}

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
            from: "0.6.7"),
        .package(
            url: "https://github.com/mobelux/swift-version-file-plugin",
            from: "0.1.0"),
        .package(
            url: "https://github.com/nicklockwood/SwiftFormat",
            from: "0.50.6")
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


#if canImport(Darwin)
import Darwin
let buildingDocs = getenv(EnvironmentKey.buildingDocs) != nil
#elseif canImport(Glibc)
import Glibc
let buildingDocs = getenv(EnvironmentKey.buildingDocs) != nil
#else
let buildingDocs = false
#endif

// Only require the docc plugin when building documentation
package.dependencies += buildingDocs ? [
  .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
] : []
