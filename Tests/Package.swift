// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BridgeTemplateTests",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "BridgeTemplateTests",
            targets: ["BridgeTemplateTests"]),
    ],
    dependencies: [
        .package(path: "../Core"),
        .package(path: "../Modules/PersonalAssistant"),
        .package(path: "../Modules/Projects"),
        .package(path: "../Modules/Documents"),
        .package(path: "../Modules/Settings"),
        .package(path: "../Modules/Terminal")
    ],
    targets: [
        .target(
            name: "BridgeTemplateTests",
            dependencies: [
                .product(name: "BridgeCore", package: "Core"),
                .product(name: "PersonalAssistant", package: "PersonalAssistant"),
                .product(name: "Projects", package: "Projects"),
                .product(name: "Documents", package: "Documents"),
                .product(name: "Settings", package: "Settings"),
                .product(name: "Terminal", package: "Terminal")
            ],
            path: ".",
            sources: [
                "IntegrationTests",
                "Performance",
                "Regression"
            ]
        ),
        .testTarget(
            name: "BridgeTemplateTestsTests",
            dependencies: ["BridgeTemplateTests"],
            path: "."
        )
    ]
)