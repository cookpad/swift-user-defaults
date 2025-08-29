// swift-tools-version:6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-user-defaults",
    platforms: [
        .macOS(.v15),
        .iOS(.v15),
        .watchOS(.v7),
        .tvOS(.v15)
    ],
    products: [
        .library(name: "SwiftUserDefaults", targets: ["SwiftUserDefaults"]),
    ],
    targets: [
        .target(name: "SwiftUserDefaults", dependencies: [], resources: [.copy("PrivacyInfo.xcprivacy")]),
        .testTarget(name: "SwiftUserDefaultsTests", dependencies: ["SwiftUserDefaults"])
    ]
)
