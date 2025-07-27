// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

/// # Settings Package
///
/// A comprehensive settings management module that provides system configuration,
/// appearance customization, module management, and application information.
///
/// ## Overview
///
/// The Settings module is built using the UniversalTemplate system and provides
/// a complete settings and configuration solution. It includes:
///
/// - **General Settings**: System-wide preferences and configuration
/// - **Appearance Settings**: Theme and visual customization
/// - **Module Management**: Hot-swappable module configuration
/// - **About Section**: Application information and updates
/// - **Hot-Swappable**: Update features without restart
///
/// ## Architecture
///
/// ```
/// Settings/
/// ├── Sources/
/// │   └── Settings/
/// │       └── SettingsModule.swift      # Main module implementation
/// ├── SubModules/
/// │   ├── General/                      # General settings
/// │   ├── Appearance/                   # Theme customization
/// │   ├── Modules/                      # Module management
/// │   └── About/                        # App information
/// ├── Tests/
/// │   └── SettingsTests/
/// └── CICD/
///     └── Workflows/                   # GitHub Actions automation
/// ```
let package = Package(
    name: "Settings",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
        .watchOS(.v10),
        .tvOS(.v17),
        .visionOS(.v1)
    ],
    products: [
        // The universal library that can be used anywhere
        .library(
            name: "Settings",
            targets: ["Settings"]
        ),
    ],
    dependencies: [
        // Swift DocC Plugin for documentation generation
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.3.0"),
        // Swift Argument Parser for CLI
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0"),
        // For testing
        .package(url: "https://github.com/apple/swift-testing", from: "0.6.0")
    ],
    targets: [
        // Main library target
        .target(
            name: "Settings",
            dependencies: [],
            path: "Sources/Settings",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
                .enableUpcomingFeature("BareSlashRegexLiterals")
            ]
        ),
        // Test target
        .testTarget(
            name: "SettingsTests",
            dependencies: [
                "Settings",
                .product(name: "Testing", package: "swift-testing")
            ],
            path: "Tests/SettingsTests"
        )
    ]
)

// MARK: - Build Configurations

// Custom build settings for different hierarchy levels
let hierarchyConfigurations = [
    "MODULE": ["-D", "HIERARCHY_MODULE"],
    "SUBMODULE": ["-D", "HIERARCHY_SUBMODULE"],
    "EPIC": ["-D", "HIERARCHY_EPIC"],
    "STORY": ["-D", "HIERARCHY_STORY"],
    "FEATURE": ["-D", "HIERARCHY_FEATURE"],
    "TASK": ["-D", "HIERARCHY_TASK"],
    "WIDGET": ["-D", "HIERARCHY_WIDGET"],
    "COMPONENT": ["-D", "HIERARCHY_COMPONENT"]
]