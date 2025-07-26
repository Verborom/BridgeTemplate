// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DashboardModule",
    platforms: [
        .macOS(.v13),
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "DashboardModule",
            targets: ["DashboardModule"]
        ),
    ],
    dependencies: [
        // Core Bridge dependencies would go here
    ],
    targets: [
        .target(
            name: "DashboardModule",
            dependencies: [],
            path: "Sources"
        ),
        .testTarget(
            name: "DashboardModuleTests",
            dependencies: ["DashboardModule"],
            path: "Tests"
        ),
    ]
)