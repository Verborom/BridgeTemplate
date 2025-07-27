// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "BridgeCore",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "BridgeCore",
            targets: ["BridgeCore"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "BridgeCore",
            dependencies: [],
            path: ".",
            sources: [
                "BridgeModule.swift",
                "ModuleManager/ModuleManager.swift",
                "VersionManager/VersionManager.swift",
                "MockModules.swift"
            ],
            swiftSettings: [
                .define("BRIDGE_CORE")
            ]
        )
    ]
)