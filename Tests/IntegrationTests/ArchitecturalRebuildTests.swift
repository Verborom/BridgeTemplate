/// # Architectural Rebuild Integration Tests
///
/// Comprehensive test suite validating the complete architectural rebuild
/// including dynamic module discovery, UniversalTemplate system, and
/// seamless integration of real and mock modules.
///
/// ## Overview
/// These tests verify:
/// - All 5 modules discover and load correctly
/// - UniversalTemplate generates proper hierarchies
/// - Dynamic discovery replaces hardcoded systems
/// - Hot-swapping functionality preserved
/// - Terminal real functionality maintained
/// - Navigation and UI integration works
///
/// ## Test Categories
/// ### Module Discovery Tests
/// - ``testModuleDiscovery()``
/// - ``testAllModulesFound()``
/// - ``testModuleMetadataLoading()``
///
/// ### Dynamic Loading Tests
/// - ``testDynamicModuleLoading()``
/// - ``testModuleInstantiation()``
/// - ``testDependencyResolution()``
///
/// ### Template System Tests
/// - ``testUniversalTemplateGeneration()``
/// - ``testSubModuleCreation()``
/// - ``testHierarchyNavigation()``
///
/// ### Integration Tests
/// - ``testMainAppIntegration()``
/// - ``testModuleNavigation()``
/// - ``testHotSwapping()``
import XCTest
@testable import BridgeCore
@testable import PersonalAssistant
@testable import Projects
@testable import Documents
@testable import Settings
@testable import Terminal

final class ArchitecturalRebuildTests: XCTestCase {
    var moduleManager: ModuleManager!
    var universalTemplate: UniversalTemplate!
    
    override func setUp() async throws {
        try await super.setUp()
        moduleManager = ModuleManager()
        universalTemplate = UniversalTemplate()
        
        // Wait for initial discovery
        await moduleManager.discoverAvailableModules()
    }
    
    override func tearDown() async throws {
        // Clean up loaded modules
        for moduleId in moduleManager.loadedModules.keys {
            try await moduleManager.unloadModule(identifier: moduleId)
        }
        
        moduleManager = nil
        universalTemplate = nil
        try await super.tearDown()
    }
    
    // MARK: - Module Discovery Tests
    
    /// Test that module discovery finds all 5 expected modules
    func testModuleDiscovery() async throws {
        let discoveredModules = moduleManager.availableModules
        
        XCTAssertEqual(discoveredModules.count, 5, "Should discover exactly 5 modules")
        
        let expectedModules = [
            "com.bridge.personalassistant",
            "com.bridge.projects", 
            "com.bridge.documents",
            "com.bridge.settings",
            "com.bridge.terminal"
        ]
        
        for expectedId in expectedModules {
            let found = discoveredModules.contains { $0.identifier == expectedId }
            XCTAssertTrue(found, "Should find module: \(expectedId)")
        }
    }
    
    /// Test that all discovered modules have valid metadata
    func testModuleMetadataLoading() async throws {
        for metadata in moduleManager.availableModules {
            XCTAssertFalse(metadata.name.isEmpty, "Module name should not be empty")
            XCTAssertFalse(metadata.identifier.isEmpty, "Module identifier should not be empty")
            XCTAssertFalse(metadata.versions.isEmpty, "Module should have at least one version")
            XCTAssertTrue(metadata.identifier.hasPrefix("com.bridge."), "Should use proper identifier format")
        }
    }
    
    /// Test version information is correctly parsed
    func testModuleVersions() async throws {
        let terminalModule = moduleManager.availableModules.first { $0.identifier == "com.bridge.terminal" }
        XCTAssertNotNil(terminalModule, "Terminal module should be discovered")
        XCTAssertEqual(terminalModule?.latestVersion, "1.3.0", "Terminal should be version 1.3.0")
        
        let personalAssistant = moduleManager.availableModules.first { $0.identifier == "com.bridge.personalassistant" }
        XCTAssertNotNil(personalAssistant, "Personal Assistant should be discovered")
        XCTAssertEqual(personalAssistant?.latestVersion, "1.0.0", "Personal Assistant should be version 1.0.0")
    }
    
    // MARK: - Dynamic Loading Tests
    
    /// Test that all modules can be loaded dynamically
    func testDynamicModuleLoading() async throws {
        for metadata in moduleManager.availableModules {
            let module = try await moduleManager.loadModule(identifier: metadata.identifier)
            
            XCTAssertEqual(module.id, metadata.identifier, "Module ID should match metadata")
            XCTAssertFalse(module.displayName.isEmpty, "Module should have display name")
            XCTAssertFalse(module.icon.isEmpty, "Module should have icon")
        }
        
        XCTAssertEqual(moduleManager.loadedModules.count, 5, "All 5 modules should be loaded")
    }
    
    /// Test module instantiation creates correct types
    func testModuleInstantiation() async throws {
        let personalAssistant = try await moduleManager.loadModule(identifier: "com.bridge.personalassistant")
        XCTAssertTrue(personalAssistant is PersonalAssistantModule, "Should instantiate PersonalAssistantModule")
        
        let projects = try await moduleManager.loadModule(identifier: "com.bridge.projects")
        XCTAssertTrue(projects is ProjectsModule, "Should instantiate ProjectsModule")
        
        let documents = try await moduleManager.loadModule(identifier: "com.bridge.documents") 
        XCTAssertTrue(documents is DocumentsModule, "Should instantiate DocumentsModule")
        
        let settings = try await moduleManager.loadModule(identifier: "com.bridge.settings")
        XCTAssertTrue(settings is SettingsModule, "Should instantiate SettingsModule")
        
        let terminal = try await moduleManager.loadModule(identifier: "com.bridge.terminal")
        XCTAssertTrue(terminal is TerminalModule, "Should instantiate TerminalModule")
    }
    
    /// Test dependency resolution works correctly
    func testDependencyResolution() async throws {
        // Test loading module with dependencies loads dependencies first
        for metadata in moduleManager.availableModules {
            if !metadata.dependencies.isEmpty {
                let module = try await moduleManager.loadModule(identifier: metadata.identifier)
                
                // Verify all dependencies are loaded
                for dependency in metadata.dependencies {
                    XCTAssertNotNil(moduleManager.loadedModules[dependency], 
                                   "Dependency \(dependency) should be loaded for \(metadata.identifier)")
                }
            }
        }
    }
    
    // MARK: - UniversalTemplate Tests
    
    /// Test that UniversalTemplate generates submodules correctly
    func testUniversalTemplateGeneration() async throws {
        let personalAssistant = try await moduleManager.loadModule(identifier: "com.bridge.personalassistant") as! PersonalAssistantModule
        
        // Personal Assistant should have 4 template-generated submodules
        XCTAssertEqual(personalAssistant.subModules.count, 4, "Should have 4 submodules")
        
        let expectedSubModules = [
            "com.bridge.personalassistant.taskmanagement",
            "com.bridge.personalassistant.calendar",
            "com.bridge.personalassistant.aichat", 
            "com.bridge.personalassistant.voice"
        ]
        
        for expectedId in expectedSubModules {
            XCTAssertNotNil(personalAssistant.subModules[expectedId], "Should have submodule: \(expectedId)")
        }
    }
    
    /// Test submodule creation and properties
    func testSubModuleCreation() async throws {
        let projects = try await moduleManager.loadModule(identifier: "com.bridge.projects") as! ProjectsModule
        
        // Projects should have 5 template-generated submodules
        XCTAssertEqual(projects.subModules.count, 5, "Should have 5 submodules")
        
        // Test each submodule has proper properties
        for (_, subModule) in projects.subModules {
            XCTAssertFalse(subModule.displayName.isEmpty, "Submodule should have display name")
            XCTAssertFalse(subModule.icon.isEmpty, "Submodule should have icon")
            XCTAssertTrue(subModule.id.hasPrefix("com.bridge.projects."), "Submodule should have proper ID prefix")
        }
    }
    
    /// Test that Terminal doesn't use template system (real implementation)
    func testTerminalRealImplementation() async throws {
        let terminal = try await moduleManager.loadModule(identifier: "com.bridge.terminal") as! TerminalModule
        
        // Terminal should NOT have template-generated submodules
        // It has its own sophisticated internal architecture
        XCTAssertEqual(terminal.version.major, 1, "Terminal should be version 1.x.x")
        XCTAssertEqual(terminal.version.minor, 3, "Terminal should be version 1.3.x")
        XCTAssertEqual(terminal.displayName, "Terminal", "Terminal should have correct name")
    }
    
    // MARK: - Hot-Swapping Tests
    
    /// Test hot-swapping functionality is preserved
    func testHotSwapping() async throws {
        // Load initial module
        let initialModule = try await moduleManager.loadModule(identifier: "com.bridge.personalassistant")
        let initialVersion = initialModule.version.description
        
        // Test hot-swap (this would normally load a different version)
        try await moduleManager.hotSwapModule("com.bridge.personalassistant", to: "1.0.1")
        
        // Verify module is still accessible
        XCTAssertNotNil(moduleManager.loadedModules["com.bridge.personalassistant"], 
                       "Module should still be loaded after hot-swap")
    }
    
    /// Test module unloading
    func testModuleUnloading() async throws {
        // Load a module
        _ = try await moduleManager.loadModule(identifier: "com.bridge.documents")
        XCTAssertNotNil(moduleManager.loadedModules["com.bridge.documents"], "Module should be loaded")
        
        // Unload it
        try await moduleManager.unloadModule(identifier: "com.bridge.documents")
        XCTAssertNil(moduleManager.loadedModules["com.bridge.documents"], "Module should be unloaded")
    }
    
    // MARK: - Integration Tests
    
    /// Test main app integration
    func testMainAppIntegration() async throws {
        // Simulate main app loading
        await moduleManager.discoverAvailableModules()
        
        // Load all modules like main app does
        for metadata in moduleManager.availableModules {
            _ = try await moduleManager.loadModule(identifier: metadata.identifier)
        }
        
        // Verify all modules loaded successfully
        XCTAssertEqual(moduleManager.loadedModules.count, 5, "All modules should load in main app simulation")
        
        // Test getting all modules for UI
        let allModules = moduleManager.allModules
        XCTAssertEqual(allModules.count, 5, "Should return all loaded modules")
    }
    
    /// Test navigation between modules works
    func testModuleNavigation() async throws {
        // Load all modules
        for metadata in moduleManager.availableModules {
            _ = try await moduleManager.loadModule(identifier: metadata.identifier)
        }
        
        // Test that each module provides a view
        for (_, module) in moduleManager.loadedModules {
            let view = module.view
            XCTAssertNotNil(view, "Module \(module.id) should provide a view")
        }
    }
    
    /// Test performance of dynamic system
    func testDynamicSystemPerformance() async throws {
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // Measure discovery time
        await moduleManager.discoverAvailableModules()
        let discoveryTime = CFAbsoluteTimeGetCurrent() - startTime
        
        // Discovery should be fast (under 1 second)
        XCTAssertLessThan(discoveryTime, 1.0, "Module discovery should complete quickly")
        
        let loadStartTime = CFAbsoluteTimeGetCurrent()
        
        // Measure loading time
        for metadata in moduleManager.availableModules {
            _ = try await moduleManager.loadModule(identifier: metadata.identifier)
        }
        
        let loadTime = CFAbsoluteTimeGetCurrent() - loadStartTime
        
        // Loading should be reasonable (under 3 seconds for all modules)
        XCTAssertLessThan(loadTime, 3.0, "Module loading should complete within reasonable time")
    }
}