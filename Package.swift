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
            from: "0.6.7"),
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

// MARK: - Additional Dependencies for CI

enum CI: String {
    static let environmentVariable = "LYTICS_SWIFT_CI"

    case release = "BUILDING_FOR_RELEASE"

    init?(cString: UnsafeMutablePointer<CChar>?) {
        guard let cString else {
            return nil
        }
        self.init(rawValue: String(cString: cString))
    }
}

let workflow: CI?
#if canImport(Darwin)
import Darwin
workflow = CI(cString: getenv(CI.environmentVariable))
#elseif canImport(Glibc)
import Glibc
workflow = CI(cString: getenv(CI.environmentVariable))
#else
workflow = nil
#endif

// Only require additional dependencies when needed for CI
switch workflow {
case .release:
    package.dependencies += [
        .package(url: "https://github.com/mobelux/swift-version-file-plugin", from: "0.1.0")
    ]
case .none:
    break
}
