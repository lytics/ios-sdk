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

/// A representation of CI workflows that require additional Swift Package Manager plugins.
enum CIWorkflow: String {
    /// The environment variable used to indicate that a particular workflow is active.
    static let environmentVariable = "LYTICS_SWIFT_CI"

    case documentation = "BUILDING_FOR_DOCUMENTATION_GENERATION"
    case release = "BUILDING_FOR_RELEASE"

    init?(cString: UnsafeMutablePointer<CChar>?) {
        guard let cString else {
            return nil
        }
        self.init(rawValue: String(cString: cString))
    }
}

let workflow: CIWorkflow?
#if canImport(Darwin)
import Darwin
workflow = CIWorkflow(cString: getenv(CIWorkflow.environmentVariable))
#elseif canImport(Glibc)
import Glibc
workflow = CIWorkflow(cString: getenv(CIWorkflow.environmentVariable))
#else
workflow = nil
#endif

// Only require additional dependencies when needed for CI
switch workflow {
case .documentation:
    package.dependencies += [
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0")
    ]
case .release:
    package.dependencies += [
        .package(url: "https://github.com/mobelux/swift-version-file-plugin", from: "0.1.0")
    ]
case .none:
    break
}
