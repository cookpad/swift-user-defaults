// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-user-defaults",
    platforms: [
        .macOS(.v10_12),
        .iOS(.v11),
        .watchOS(.v7),
        .tvOS(.v10)
    ],
    products: [
        .library(name: "SwiftUserDefaults", targets: ["SwiftUserDefaults"]),
    ],
    targets: [
        .target(name: "SwiftUserDefaults", dependencies: []),
        .testTarget(name: "SwiftUserDefaultsTests", dependencies: ["SwiftUserDefaults"])
    ]
)
