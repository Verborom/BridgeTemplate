// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "BridgeTemplateApp",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "BridgeTemplateApp",
            targets: ["BridgeTemplateApp"]
        )
    ],
    dependencies: [
        .package(path: "../UniversalTemplate")
    ],
    targets: [
        .target(
            name: "BridgeTemplateApp",
            dependencies: ["UniversalTemplate"]
        ),
        .testTarget(
            name: "BridgeTemplateAppTests",
            dependencies: ["BridgeTemplateApp"]
        )
    ]
)