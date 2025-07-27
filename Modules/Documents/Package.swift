// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

/// # Documents Package
///
/// A comprehensive document management module that provides text editing, markdown preview,
/// file browsing, and search capabilities.
///
/// ## Overview
///
/// The Documents module is built using the UniversalTemplate system and provides
/// a complete document management solution. It includes:
///
/// - **Text Editor**: Rich text editing with syntax highlighting
/// - **Markdown Preview**: Live markdown rendering
/// - **File Browser**: Navigate and manage documents
/// - **Search**: Find content across all documents
/// - **Hot-Swappable**: Update features without restart
///
/// ## Architecture
///
/// ```
/// Documents/
/// ├── Sources/
/// │   └── Documents/
/// │       └── DocumentsModule.swift     # Main module implementation
/// ├── SubModules/
/// │   ├── TextEditor/                  # Text editing capabilities
/// │   ├── MarkdownPreview/             # Markdown rendering
/// │   ├── FileBrowser/                 # Document navigation
/// │   └── Search/                      # Search functionality
/// ├── Tests/
/// │   └── DocumentsTests/
/// └── CICD/
///     └── Workflows/                   # GitHub Actions automation
/// ```
let package = Package(
    name: "Documents",
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
            name: "Documents",
            targets: ["Documents"]
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
            name: "Documents",
            dependencies: [],
            path: "Sources/Documents",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
                .enableUpcomingFeature("BareSlashRegexLiterals")
            ]
        ),
        // Test target
        .testTarget(
            name: "DocumentsTests",
            dependencies: [
                "Documents",
                .product(name: "Testing", package: "swift-testing")
            ],
            path: "Tests/DocumentsTests"
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