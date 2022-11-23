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
        .plugin(
            name: "VersionFile",
            capability: .command(
                intent: .custom(
                    verb: "version-file",
                    description: "Generates a `Version.swift` file"
                ),
                permissions: [
                    .writeToPackageDirectory(reason: "This command write the new `Version.swift` to the source root.")
                ]
            ))
    ]
)
