// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-user-defaults",
    platforms: [
        .macOS(.v10_13),
        .iOS(.v12),
        .watchOS(.v7),
        .tvOS(.v12)
    ],
    products: [
        .library(name: "SwiftUserDefaults", targets: ["SwiftUserDefaults"]),
    ],
    targets: [
        .target(name: "SwiftUserDefaults", dependencies: [], resources: [.copy("PrivacyInfo.xcprivacy")]),
        .testTarget(name: "SwiftUserDefaultsTests", dependencies: ["SwiftUserDefaults"])
    ]
)
