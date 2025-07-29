// swift-tools-version: 5.9

/// # NewBridgeMac Package
///
/// Swift package configuration for the new Bridge Template macOS application
/// built with the architectural rebuild system.
///
/// ## Overview
///
/// This package integrates all the new dynamic modules and systems:
/// - Dynamic ModuleManager with runtime discovery
/// - All 5 modules (PersonalAssistant, Projects, Documents, Settings, Terminal)
/// - UniversalTemplate and TemplateInstantiator systems
/// - Professional macOS app architecture
///
/// ## Dependencies
/// - BridgeCore: Core systems and protocols
/// - All module packages for dynamic loading
/// - SwiftUI for modern app interface
///
/// ## Targets
/// - NewBridgeMac: Main application executable
/// - NewBridgeMacTests: Comprehensive test suite
import PackageDescription

let package = Package(
    name: "NewBridgeMac",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "NewBridgeMac", targets: ["NewBridgeMac"])
    ],
    dependencies: [
        // Core Bridge Template systems
        .package(path: "../../../Core"),
        
        // All modules for dynamic loading
        .package(path: "../../../Modules/PersonalAssistant"),
        .package(path: "../../../Modules/Projects"),
        .package(path: "../../../Modules/Documents"),
        .package(path: "../../../Modules/Settings"),
        .package(path: "../../../Modules/Terminal"),
        
        // UniversalTemplate system
        .package(path: "../../../UniversalTemplate")
    ],
    targets: [
        .executableTarget(
            name: "NewBridgeMac",
            dependencies: [
                .product(name: "BridgeCore", package: "Core"),
                .product(name: "PersonalAssistant", package: "PersonalAssistant"),
                .product(name: "Projects", package: "Projects"),
                .product(name: "Documents", package: "Documents"),
                .product(name: "Settings", package: "Settings"),
                .product(name: "Terminal", package: "Terminal"),
                .product(name: "UniversalTemplate", package: "UniversalTemplate")
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "NewBridgeMacTests",
            dependencies: ["NewBridgeMac"],
            path: "Tests"
        )
    ]
)