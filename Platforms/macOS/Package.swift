// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "BridgeMac",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "BridgeMac", targets: ["BridgeMac"])
    ],
    dependencies: [
        // Terminal module dependency - LOCAL PATH
        .package(path: "../../Modules/Terminal"),
        // Dashboard module dependency - LOCAL PATH
        .package(path: "../../Modules/Dashboard"),
        // Projects module dependency - LOCAL PATH (when available)
        // .package(path: "../../Modules/Projects")
    ],
    targets: [
        .executableTarget(
            name: "BridgeMac",
            dependencies: [
                .product(name: "Terminal", package: "Terminal"),
                .product(name: "Dashboard", package: "Dashboard")
            ],
            path: ".",
            sources: ["BridgeMac.swift"],
            resources: [],
            swiftSettings: [
                .define("BRIDGE_MACOS"),
                .unsafeFlags(["-enable-bare-slash-regex"])
            ]
        )
    ]
)