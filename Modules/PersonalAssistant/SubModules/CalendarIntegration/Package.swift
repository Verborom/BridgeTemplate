// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

/// # CalendarIntegration Package
///
/// The revolutionary template system that powers every component in Bridge Template,
/// from the highest-level Module down to the smallest Task. This single template
/// provides complete CICD, testing, documentation, and versioning for ANY hierarchy level.
///
/// ## Overview
///
/// CalendarIntegration is the foundation of infinite recursive modularity. Every component,
/// regardless of its position in the hierarchy (Module, Submodule, Epic, Story, Feature,
/// Task, etc.), uses this exact same template structure. This enables:
///
/// - **Infinite Nesting**: Any component can contain any other component
/// - **Complete Automation**: Full CICD at every level
/// - **Universal Interface**: Same API for all hierarchy levels
/// - **Runtime Instantiation**: Create new components dynamically
/// - **Zero Duplication**: One template to rule them all
///
/// ## Architecture
///
/// ```
/// CalendarIntegration/
/// ├── Sources/
/// │   ├── UniversalComponent.swift      # The universal protocol
/// │   ├── ComponentFactory.swift        # Runtime instantiation
/// │   ├── HierarchyManager.swift       # Manage parent-child relationships
/// │   └── Implementations/             # Example implementations
/// ├── Tests/
/// │   └── CalendarIntegrationTests/
/// ├── CICD/
/// │   ├── Workflows/                   # GitHub Actions for any component
/// │   └── Scripts/                     # Build/test/deploy scripts
/// └── Documentation/
///     └── CalendarIntegration.docc/      # Swift DocC documentation
/// ```
let package = Package(
    name: "CalendarIntegration",
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
            name: "CalendarIntegration",
            targets: ["CalendarIntegration"]
        ),
        // Executable for CLI operations
        .executable(
            name: "universal-cli",
            targets: ["UniversalCLI"]
        )
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
            name: "CalendarIntegration",
            dependencies: [],
            path: "Sources/CalendarIntegration",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
                .enableUpcomingFeature("BareSlashRegexLiterals")
            ]
        ),
        // CLI for template operations
        .executableTarget(
            name: "UniversalCLI",
            dependencies: [
                "CalendarIntegration",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ],
            path: "Sources/UniversalCLI"
        ),
        // Test target
        .testTarget(
            name: "CalendarIntegrationTests",
            dependencies: [
                "CalendarIntegration",
                .product(name: "Testing", package: "swift-testing")
            ],
            path: "Tests/CalendarIntegrationTests"
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