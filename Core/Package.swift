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
    dependencies: [
        // Real module dependencies
        .package(path: "../Modules/Terminal"),
        .package(path: "../Modules/Projects"),
        .package(path: "../Modules/PersonalAssistant"),
        .package(path: "../Modules/Documents"),
        .package(path: "../Modules/Settings"),
        .package(path: "../UniversalTemplate")
    ],
    targets: [
        .target(
            name: "BridgeCore",
            dependencies: [
                .product(name: "Terminal", package: "Terminal"),
                .product(name: "Projects", package: "Projects"),
                .product(name: "PersonalAssistant", package: "PersonalAssistant"),
                .product(name: "Documents", package: "Documents"),
                .product(name: "Settings", package: "Settings"),
                .product(name: "UniversalTemplate", package: "UniversalTemplate")
            ],
            path: ".",
            sources: [
                "BridgeModule.swift",
                "ModuleManager/ModuleManager.swift",
                "ModuleManager/ModuleDiscovery.swift",
                "VersionManager/VersionManager.swift",
                "UniversalTemplate.swift"
            ],
            swiftSettings: [
                .define("BRIDGE_CORE")
            ]
        )
    ]
)