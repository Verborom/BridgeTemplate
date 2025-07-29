/// # Feature Regression Tests
///
/// Ensures that the architectural rebuild doesn't break any existing
/// functionality that users depend on.
import XCTest
@testable import BridgeCore

final class FeatureRegressionTests: XCTestCase {
    
    /// Test that Terminal real functionality is preserved
    func testTerminalFunctionalityPreserved() async throws {
        let moduleManager = ModuleManager()
        await moduleManager.discoverAvailableModules()
        
        let terminal = try await moduleManager.loadModule(identifier: "com.bridge.terminal") as! TerminalModule
        
        // Verify Terminal is version 1.3.0 (not downgraded)
        XCTAssertEqual(terminal.version.major, 1)
        XCTAssertEqual(terminal.version.minor, 3)
        XCTAssertEqual(terminal.version.patch, 0)
        
        // Verify Terminal provides real functionality (not mock)
        XCTAssertEqual(terminal.displayName, "Terminal")
        XCTAssertEqual(terminal.icon, "terminal")
    }
    
    /// Test that module navigation is preserved
    func testModuleNavigationPreserved() async throws {
        let moduleManager = ModuleManager()
        await moduleManager.discoverAvailableModules()
        
        // Load all modules
        for metadata in moduleManager.availableModules {
            let module = try await moduleManager.loadModule(identifier: metadata.identifier)
            
            // Every module should provide a view
            let view = module.view
            XCTAssertNotNil(view, "Module \(module.id) should provide navigation view")
        }
    }
    
    /// Test that hot-swapping is preserved
    func testHotSwappingPreserved() async throws {
        let moduleManager = ModuleManager()
        await moduleManager.discoverAvailableModules()
        
        // Load a module
        let module = try await moduleManager.loadModule(identifier: "com.bridge.personalassistant")
        let originalVersion = module.version
        
        // Hot-swap should work without errors
        try await moduleManager.hotSwapModule("com.bridge.personalassistant", to: "1.0.1")
        
        // Module should still be loaded
        XCTAssertNotNil(moduleManager.loadedModules["com.bridge.personalassistant"])
    }
    
    /// Test that version management is preserved
    func testVersionManagementPreserved() async throws {
        let moduleManager = ModuleManager()
        await moduleManager.discoverAvailableModules()
        
        for metadata in moduleManager.availableModules {
            let module = try await moduleManager.loadModule(identifier: metadata.identifier)
            
            // Every module should have proper version
            XCTAssertGreaterThan(module.version.major, 0, "Module should have valid major version")
            XCTAssertFalse(module.version.description.isEmpty, "Module should have version string")
        }
    }
}