// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

/// # PersonalAssistant Package
///
/// A comprehensive personal assistant module that demonstrates the UniversalTemplate system
/// working correctly. This module provides task management, calendar integration, AI chat,
/// and voice command capabilities.
///
/// ## Overview
///
/// PersonalAssistant is the first module created using the revolutionary TemplateInstantiator
/// system. It showcases:
///
/// - **Modular Architecture**: Four distinct submodules working together
/// - **Complete Automation**: Full CICD at module and submodule level
/// - **Hot-Swappable**: Runtime updates without restart
/// - **Universal Interface**: Consistent API across all components
/// - **Professional UI**: Navigable mockup demonstrating the architecture
///
/// ## Architecture
///
/// ```
/// PersonalAssistant/
/// ├── Sources/
/// │   ├── PersonalAssistant.swift      # Main module implementation
/// │   ├── PersonalAssistantView.swift  # Main UI view
/// │   └── SubModules/                  # Submodule integrations
/// ├── SubModules/
/// │   ├── TaskManagement/              # Task tracking and organization
/// │   ├── CalendarIntegration/         # Calendar and scheduling
/// │   ├── AIChat/                      # AI-powered chat interface
/// │   └── VoiceCommands/               # Voice control system
/// ├── Tests/
/// │   └── PersonalAssistantTests/
/// └── CICD/
///     └── Workflows/                   # GitHub Actions automation
/// ```
let package = Package(
    name: "PersonalAssistant",
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
            name: "PersonalAssistant",
            targets: ["PersonalAssistant"]
        ),
    ],
    dependencies: [
        // Swift DocC Plugin for documentation generation
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.3.0"),
        // Swift Argument Parser for CLI
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0"),
        // For testing
        .package(url: "https://github.com/apple/swift-testing", from: "0.6.0"),
        // Submodules
        .package(path: "./SubModules/TaskManagement"),
        .package(path: "./SubModules/CalendarIntegration"),
        .package(path: "./SubModules/AIChat"),
        .package(path: "./SubModules/VoiceCommands")
    ],
    targets: [
        // Main library target
        .target(
            name: "PersonalAssistant",
            dependencies: [],
            path: "Sources/PersonalAssistant",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
                .enableUpcomingFeature("BareSlashRegexLiterals")
            ]
        ),
        // Test target
        .testTarget(
            name: "PersonalAssistantTests",
            dependencies: [
                "PersonalAssistant",
                .product(name: "Testing", package: "swift-testing")
            ],
            path: "Tests/PersonalAssistantTests"
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