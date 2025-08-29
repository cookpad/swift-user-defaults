// swift-tools-version:6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ExampleKit",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(name: "ExampleKit", targets: ["ExampleKit"])
    ],
    dependencies: [
        .package(path: "../../")
    ],
    targets: [
        .target(name: "ExampleKit", dependencies: [.product(name: "SwiftUserDefaults", package: "swift-user-defaults")])
    ]
)
