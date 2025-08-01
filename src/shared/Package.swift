// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BridgeCore",
    platforms: [
        .macOS(.v13),
        .iOS(.v16)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "BridgeCore",
            targets: ["BridgeCore"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // Uncomment to add dependencies:
        // .package(url: "https://github.com/apple/swift-algorithms", from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "BridgeCore",
            dependencies: [],
            resources: [
                // Add resource files here if needed
                // .process("Resources")
            ]
        ),
        .testTarget(
            name: "BridgeCoreTests",
            dependencies: ["BridgeCore"]),
    ]
)