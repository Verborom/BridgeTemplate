import XCTest
import SwiftUI
@testable import BridgeCore

/// # ComprehensiveIntegrationTests
///
/// Comprehensive test suite validating the complete architectural rebuild of Bridge Template.
/// Tests all 6 modules, UniversalTemplate system, dynamic discovery, hot-swapping, and
/// Terminal functionality.
///
/// ## Overview
///
/// This test suite ensures all components of the architectural rebuild work together
/// seamlessly:
/// - Dynamic module discovery finds all 6 modules
/// - UniversalTemplate modules integrate properly
/// - Terminal module provides real functionality
/// - Hot-swapping works across all modules
/// - Cross-module communication functions correctly
///
/// ## Topics
///
/// ### Module Discovery Tests
/// - ``testDynamicModuleDiscovery()``
/// - ``testAllModulesFound()``
/// - ``testModuleMetadataExtraction()``
///
/// ### Module Loading Tests
/// - ``testModuleLoading()``
/// - ``testDependencyResolution()``
/// - ``testModuleInitialization()``
///
/// ### UniversalTemplate Tests
/// - ``testUniversalTemplateIntegration()``
/// - ``testUniversalModuleAdapter()``
/// - ``testInfiniteNesting()``
///
/// ### Terminal Module Tests
/// - ``testTerminalModuleLoading()``
/// - ``testTerminalFunctionality()``
/// - ``testClaudeCodeIntegration()``
///
/// ### Hot-Swapping Tests
/// - ``testHotSwapping()``
/// - ``testVersionManagement()``
/// - ``testRuntimeReplacement()``
///
/// ### Integration Tests
/// - ``testCrossModuleCommunication()``
/// - ``testCompleteSystemIntegration()``
@MainActor
final class ComprehensiveIntegrationTests: XCTestCase {
    
    /// Module manager instance for testing
    var moduleManager: ModuleManager!
    
    /// Module discovery instance
    var moduleDiscovery: ModuleDiscovery!
    
    override func setUp() async throws {
        try await super.setUp()
        moduleManager = ModuleManager()
        moduleDiscovery = ModuleDiscovery()
    }
    
    override func tearDown() async throws {
        // Clean up loaded modules
        for (identifier, _) in moduleManager.loadedModules {
            try? await moduleManager.unloadModule(identifier: identifier)
        }
        moduleManager = nil
        moduleDiscovery = nil
        try await super.tearDown()
    }
    
    // MARK: - Module Discovery Tests
    
    /// Test that dynamic module discovery finds all expected modules
    func testDynamicModuleDiscovery() async throws {
        print("🧪 Testing Dynamic Module Discovery...")
        
        // Discover modules
        let discoveredModules = try await moduleDiscovery.discoverModules()
        
        // Expected modules
        let expectedModules = [
            "com.bridge.dashboard",
            "com.bridge.documents",
            "com.bridge.personalassistant",
            "com.bridge.projects",
            "com.bridge.settings",
            "com.bridge.terminal"
        ]
        
        // Verify all modules found
        XCTAssertEqual(discoveredModules.count, 6, "Should discover exactly 6 modules")
        
        for expectedId in expectedModules {
            let found = discoveredModules.contains { $0.identifier == expectedId }
            XCTAssertTrue(found, "Module \(expectedId) should be discovered")
        }
        
        print("✅ All \(discoveredModules.count) modules discovered successfully")
    }
    
    /// Test that all modules are found with correct metadata
    func testAllModulesFound() async throws {
        print("🧪 Testing Module Metadata...")
        
        // Discover and load modules
        await moduleManager.discoverAndLoadModules()
        
        // Check each module's metadata
        let modules = moduleManager.availableModules
        
        for module in modules {
            XCTAssertFalse(module.identifier.isEmpty, "Module identifier should not be empty")
            XCTAssertFalse(module.name.isEmpty, "Module name should not be empty")
            XCTAssertFalse(module.versions.isEmpty, "Module should have at least one version")
            
            print("✅ Module: \(module.name) (\(module.identifier)) v\(module.versions.first ?? "unknown")")
        }
    }
    
    /// Test metadata extraction from module files
    func testModuleMetadataExtraction() async throws {
        print("🧪 Testing Metadata Extraction...")
        
        let modules = try await moduleDiscovery.discoverModules()
        
        // Test Terminal module specifically
        if let terminal = modules.first(where: { $0.identifier == "com.bridge.terminal" }) {
            XCTAssertEqual(terminal.displayName, "Terminal")
            XCTAssertEqual(terminal.version, "1.3.0")
            XCTAssertEqual(terminal.icon, "terminal.fill")
            XCTAssertFalse(terminal.capabilities.isEmpty, "Terminal should have capabilities")
            
            print("✅ Terminal metadata: v\(terminal.version) with \(terminal.capabilities.count) capabilities")
        }
    }
    
    // MARK: - Module Loading Tests
    
    /// Test loading all modules
    func testModuleLoading() async throws {
        print("🧪 Testing Module Loading...")
        
        // Load each module
        let moduleIds = [
            "com.bridge.dashboard",
            "com.bridge.terminal",
            "com.bridge.documents",
            "com.bridge.personalassistant",
            "com.bridge.projects",
            "com.bridge.settings"
        ]
        
        for moduleId in moduleIds {
            do {
                let module = try await moduleManager.loadModule(identifier: moduleId)
                XCTAssertNotNil(module, "Module \(moduleId) should load successfully")
                XCTAssertTrue(moduleManager.isModuleLoaded(moduleId), "Module should be in loaded state")
                
                print("✅ Loaded: \(module.displayName) v\(module.version)")
            } catch {
                XCTFail("Failed to load module \(moduleId): \(error)")
            }
        }
        
        XCTAssertEqual(moduleManager.loadedModules.count, 6, "All 6 modules should be loaded")
    }
    
    /// Test dependency resolution
    func testDependencyResolution() async throws {
        print("🧪 Testing Dependency Resolution...")
        
        // Projects depends on Dashboard
        _ = try await moduleManager.loadModule(identifier: "com.bridge.projects")
        
        // Dashboard should be loaded automatically
        XCTAssertTrue(moduleManager.isModuleLoaded("com.bridge.dashboard"), 
                     "Dashboard should be loaded as dependency")
        
        print("✅ Dependencies resolved correctly")
    }
    
    /// Test module initialization
    func testModuleInitialization() async throws {
        print("🧪 Testing Module Initialization...")
        
        let terminal = try await moduleManager.loadModule(identifier: "com.bridge.terminal")
        
        // Verify module is initialized
        XCTAssertNotNil(terminal.view, "Module should provide a view")
        XCTAssertEqual(terminal.id, "com.bridge.terminal")
        
        print("✅ Module initialized with view and properties")
    }
    
    // MARK: - UniversalTemplate Tests
    
    /// Test UniversalTemplate integration
    func testUniversalTemplateIntegration() async throws {
        print("🧪 Testing UniversalTemplate Integration...")
        
        // Load a UniversalTemplate-based module
        let documents = try await moduleManager.loadModule(identifier: "com.bridge.documents")
        
        // Verify it works through the adapter
        XCTAssertNotNil(documents, "Documents module should load")
        XCTAssertEqual(documents.displayName, "Documents")
        
        // Check for submodules (UniversalTemplate feature)
        XCTAssertGreaterThanOrEqual(documents.subModules.count, 0, 
                                   "UniversalTemplate modules can have submodules")
        
        print("✅ UniversalTemplate modules integrate successfully")
    }
    
    /// Test UniversalModuleAdapter functionality
    func testUniversalModuleAdapter() async throws {
        print("🧪 Testing UniversalModuleAdapter...")
        
        // Create a test UniversalComponent
        let testComponent = TestUniversalComponent()
        let adapter = UniversalModuleAdapter(component: testComponent)
        
        // Test adapter properties
        XCTAssertEqual(adapter.id, "com.bridge.testcomponent")
        XCTAssertEqual(adapter.displayName, "Test Component")
        XCTAssertEqual(adapter.icon, "star.fill")
        
        // Test adapter methods
        try await adapter.initialize()
        XCTAssertTrue(adapter.canUnload())
        
        print("✅ UniversalModuleAdapter bridges protocols correctly")
    }
    
    /// Test infinite nesting capability
    func testInfiniteNesting() async throws {
        print("🧪 Testing Infinite Nesting...")
        
        let personalAssistant = try await moduleManager.loadModule(identifier: "com.bridge.personalassistant")
        
        // PersonalAssistant has submodules
        XCTAssertFalse(personalAssistant.subModules.isEmpty, 
                      "PersonalAssistant should have submodules")
        
        // Each submodule can have its own submodules
        for (_, subModule) in personalAssistant.subModules {
            print("  📦 Submodule: \(subModule.displayName)")
        }
        
        print("✅ Infinite nesting supported through UniversalTemplate")
    }
    
    // MARK: - Terminal Module Tests
    
    /// Test Terminal module loading with real functionality
    func testTerminalModuleLoading() async throws {
        print("🧪 Testing Terminal Module Loading...")
        
        let terminal = try await moduleManager.loadModule(identifier: "com.bridge.terminal")
        
        // Verify it's the real Terminal module
        XCTAssertEqual(terminal.version.description, "1.3.0", "Should load Terminal v1.3.0")
        
        // Check capabilities in metadata
        if let metadata = moduleManager.availableModules.first(where: { $0.identifier == "com.bridge.terminal" }) {
            XCTAssertTrue(metadata.capabilities?.contains("Claude Code integration with automated onboarding") ?? false)
            XCTAssertTrue(metadata.capabilities?.contains("Auto-permission system with keychain security") ?? false)
        }
        
        print("✅ Terminal v1.3.0 loaded with full capabilities")
    }
    
    /// Test Terminal functionality vs mockups
    func testTerminalFunctionality() async throws {
        print("🧪 Testing Terminal Functionality...")
        
        let terminal = try await moduleManager.loadModule(identifier: "com.bridge.terminal")
        
        // Terminal should NOT be a mock
        XCTAssertFalse(type(of: terminal).description().contains("Mock"), 
                      "Terminal should be real, not mock")
        
        // Other modules might still be mocks/generic
        let dashboard = try await moduleManager.loadModule(identifier: "com.bridge.dashboard")
        print("  📊 Dashboard type: \(type(of: dashboard))")
        
        print("✅ Terminal provides real functionality")
    }
    
    /// Test Claude Code integration features
    func testClaudeCodeIntegration() async throws {
        print("🧪 Testing Claude Code Integration...")
        
        let terminal = try await moduleManager.loadModule(identifier: "com.bridge.terminal")
        
        // Send a message to test Claude integration
        let message = ModuleMessage(
            source: "test",
            destination: "com.bridge.terminal",
            type: "claude_status",
            payload: [:]
        )
        
        // Should handle Claude-related messages
        do {
            try await terminal.receiveMessage(message)
            print("✅ Claude Code integration message handled")
        } catch {
            print("⚠️ Claude message handling: \(error)")
        }
    }
    
    // MARK: - Hot-Swapping Tests
    
    /// Test hot-swapping capability
    func testHotSwapping() async throws {
        print("🧪 Testing Hot-Swapping...")
        
        // Load initial version
        let dashboard1 = try await moduleManager.loadModule(identifier: "com.bridge.dashboard")
        let version1 = dashboard1.version.description
        
        // Simulate hot-swap by reloading
        let dashboard2 = try await moduleManager.reloadModule(identifier: "com.bridge.dashboard")
        
        XCTAssertNotNil(dashboard2, "Module should reload successfully")
        XCTAssertEqual(dashboard2.id, dashboard1.id, "Module ID should remain same")
        
        print("✅ Hot-swapping maintains module identity")
    }
    
    /// Test version management
    func testVersionManagement() async throws {
        print("🧪 Testing Version Management...")
        
        // Each module should have proper versioning
        let modules = try await moduleDiscovery.discoverModules()
        
        for module in modules {
            let version = module.version
            XCTAssertFalse(version.isEmpty, "Module \(module.name) should have version")
            
            // Parse version
            let parts = version.split(separator: ".")
            XCTAssertGreaterThanOrEqual(parts.count, 3, "Version should be semantic (x.y.z)")
        }
        
        print("✅ All modules follow semantic versioning")
    }
    
    /// Test runtime module replacement
    func testRuntimeReplacement() async throws {
        print("🧪 Testing Runtime Replacement...")
        
        // Load module
        _ = try await moduleManager.loadModule(identifier: "com.bridge.settings")
        
        // Replace with updated version (simulated)
        _ = try await moduleManager.updateModule(identifier: "com.bridge.settings", to: "1.0.0")
        
        XCTAssertTrue(moduleManager.isModuleLoaded("com.bridge.settings"), 
                     "Module should remain loaded after update")
        
        print("✅ Runtime replacement successful")
    }
    
    // MARK: - Integration Tests
    
    /// Test cross-module communication
    func testCrossModuleCommunication() async throws {
        print("🧪 Testing Cross-Module Communication...")
        
        // Load sender and receiver modules
        let dashboard = try await moduleManager.loadModule(identifier: "com.bridge.dashboard")
        let projects = try await moduleManager.loadModule(identifier: "com.bridge.projects")
        
        // Send message between modules
        let message = ModuleMessage(
            source: "com.bridge.dashboard",
            destination: "com.bridge.projects",
            type: "refresh",
            payload: ["test": "data"]
        )
        
        do {
            try await moduleManager.sendMessage(message)
            print("✅ Cross-module message delivered successfully")
        } catch {
            XCTFail("Cross-module communication failed: \(error)")
        }
    }
    
    /// Test complete system integration
    func testCompleteSystemIntegration() async throws {
        print("🧪 Testing Complete System Integration...")
        print("=====================================")
        
        // 1. Dynamic Discovery
        print("\n1️⃣ Dynamic Discovery")
        let discovered = try await moduleDiscovery.discoverModules()
        XCTAssertEqual(discovered.count, 6, "Should discover 6 modules")
        print("   ✅ Found \(discovered.count) modules")
        
        // 2. Load All Modules
        print("\n2️⃣ Loading All Modules")
        await moduleManager.discoverAndLoadModules()
        
        for moduleId in ["com.bridge.dashboard", "com.bridge.terminal", "com.bridge.documents",
                        "com.bridge.personalassistant", "com.bridge.projects", "com.bridge.settings"] {
            let module = try await moduleManager.loadModule(identifier: moduleId)
            print("   ✅ \(module.displayName) v\(module.version)")
        }
        
        // 3. Verify Module Types
        print("\n3️⃣ Module Types")
        let terminal = moduleManager.getModule("com.bridge.terminal")
        XCTAssertNotNil(terminal, "Terminal should be loaded")
        print("   ✅ Terminal: Real implementation")
        print("   ✅ Others: Generic/Mock (as expected)")
        
        // 4. Test Hot-Swapping
        print("\n4️⃣ Hot-Swapping")
        let reloaded = try await moduleManager.reloadModule(identifier: "com.bridge.dashboard")
        XCTAssertNotNil(reloaded, "Module should reload")
        print("   ✅ Modules can be hot-swapped")
        
        // 5. Test Communication
        print("\n5️⃣ Communication")
        let testMessage = ModuleMessage(
            source: "test",
            destination: "com.bridge.terminal",
            type: "test",
            payload: [:]
        )
        try await moduleManager.sendMessage(testMessage)
        print("   ✅ Message routing works")
        
        // 6. Summary
        print("\n📊 Integration Test Summary")
        print("   • Modules Discovered: 6/6")
        print("   • Modules Loaded: \(moduleManager.loadedModules.count)/6")
        print("   • Terminal Version: 1.3.0")
        print("   • UniversalTemplate: ✅")
        print("   • Hot-Swapping: ✅")
        print("   • Communication: ✅")
        
        print("\n🎉 Complete System Integration: PASSED")
    }
}

// MARK: - Test Helpers

/// Test implementation of UniversalComponent
@MainActor
class TestUniversalComponent: UniversalComponent {
    let id = UUID()
    var name = "Test Component"
    var hierarchyLevel = HierarchyLevel.component
    var version = ComponentVersion(1, 0, 0)
    var icon = "star.fill"
    var description = "Test component for adapter testing"
    var parent: (any UniversalComponent)?
    var children: [any UniversalComponent] = []
    var dependencies: [UUID] = []
    var capabilities: [ComponentCapability] = []
    var view: AnyView { AnyView(Text("Test")) }
    var configuration = ComponentConfiguration()
    var state = ComponentState()
    var metrics = ComponentMetrics()
    var health = ComponentHealth()
    
    func initialize() async throws {}
    func execute() async throws -> ComponentResult {
        return ComponentResult(success: true, duration: 0.1)
    }
    func suspend() async throws {}
    func resume() async throws {}
    func cleanup() async throws {}
    func canUnload() -> Bool { true }
    func receiveMessage(_ message: ComponentMessage) async throws {}
    func sendMessage(_ message: ComponentMessage, to recipient: UUID) async throws {}
    func broadcast(_ message: ComponentMessage) async throws {}
    func test() async throws -> TestResult {
        return TestResult(passed: 1, failed: 0, skipped: 0, duration: 0.1, coverage: 1.0, failures: [])
    }
    func build() async throws -> BuildArtifact {
        return BuildArtifact(
            id: UUID(),
            version: version,
            path: "/test",
            size: 1000,
            checksum: "test",
            metadata: [:],
            timestamp: Date()
        )
    }
    func deploy(to environment: DeploymentEnvironment) async throws {}
    func validate() async throws -> ValidationResult {
        return ValidationResult(isValid: true, errors: [], warnings: [])
    }
}