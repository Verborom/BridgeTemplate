// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Terminal",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Terminal",
            targets: ["Terminal"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // Bridge Core dependency would go here in production
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Terminal",
            dependencies: [],
            path: "Sources"
        ),
        .testTarget(
            name: "TerminalTests",
            dependencies: ["Terminal"],
            path: "Tests"
        ),
    ]
)