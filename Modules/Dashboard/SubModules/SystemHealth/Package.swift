// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SystemHealth",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "SystemHealth",
            targets: ["SystemHealth"]
        ),
    ],
    dependencies: [
        // Bridge Template Core dependency would go here
    ],
    targets: [
        .target(
            name: "SystemHealth",
            dependencies: [],
            path: "Sources"
        ),
        .testTarget(
            name: "SystemHealthTests",
            dependencies: ["SystemHealth"],
            path: "Tests"
        ),
    ]
)