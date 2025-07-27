// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

/// # Projects Package
///
/// A comprehensive project management module that provides project browsing, AI assistance,
/// Git integration, and build system management capabilities.
///
/// ## Overview
///
/// The Projects module is built using the UniversalTemplate system and demonstrates
/// the power of modular architecture. It provides:
///
/// - **Project Browser**: Browse and manage all your projects
/// - **AI Assistant**: Get intelligent suggestions for your code
/// - **Git Integration**: Manage version control seamlessly
/// - **Build System**: Configure and run builds
/// - **Hot-Swappable**: Update features without restart
///
/// ## Architecture
///
/// ```
/// Projects/
/// ├── Sources/
/// │   └── Projects/
/// │       ├── ProjectsModule.swift      # Main module implementation
/// │       └── Supporting files...       # Component implementations
/// ├── SubModules/
/// │   ├── ProjectBrowser/              # Browse projects
/// │   ├── AIAssistant/                 # AI-powered assistance
/// │   ├── GitIntegration/              # Version control
/// │   └── BuildSystem/                 # Build management
/// ├── Tests/
/// │   └── ProjectsTests/
/// └── CICD/
///     └── Workflows/                   # GitHub Actions automation
/// ```
let package = Package(
    name: "Projects",
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
            name: "Projects",
            targets: ["Projects"]
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
            name: "Projects",
            dependencies: [],
            path: "Sources/Projects",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
                .enableUpcomingFeature("BareSlashRegexLiterals")
            ]
        ),
        // Test target
        .testTarget(
            name: "ProjectsTests",
            dependencies: [
                "Projects",
                .product(name: "Testing", package: "swift-testing")
            ],
            path: "Tests/ProjectsTests"
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