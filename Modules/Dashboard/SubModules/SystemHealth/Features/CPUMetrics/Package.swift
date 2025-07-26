// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CPUMetrics",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "CPUMetrics",
            targets: ["CPUMetrics"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "CPUMetrics",
            dependencies: [],
            path: "Sources"
        ),
        .testTarget(
            name: "CPUMetricsTests",
            dependencies: ["CPUMetrics"],
            path: "Tests"
        ),
    ]
)