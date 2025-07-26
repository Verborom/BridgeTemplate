import XCTest
@testable import BridgeCore

final class BridgeCoreTests: XCTestCase {
    func testGreeting() throws {
        // Given
        let bridgeCore = BridgeCore()
        
        // When
        let greeting = bridgeCore.greeting()
        
        // Then
        XCTAssertEqual(greeting, "Welcome to Bridge Template v1.0.0")
    }
    
    func testPlatformNames() throws {
        // Test macOS platform
        XCTAssertEqual(Platform.macOS.name, "macOS")
        
        // Test iOS platform
        XCTAssertEqual(Platform.iOS.name, "iOS")
    }
    
    func testModuleConfiguration() throws {
        // Given
        let settings = ["apiKey": "test123", "debug": true]
        
        // When
        let config = ModuleConfiguration(
            platform: .iOS,
            environment: .development,
            settings: settings
        )
        
        // Then
        XCTAssertEqual(config.platform.name, "iOS")
        if case .development = config.environment {
            // Success
        } else {
            XCTFail("Expected development environment")
        }
        XCTAssertEqual(config.settings["apiKey"] as? String, "test123")
        XCTAssertEqual(config.settings["debug"] as? Bool, true)
    }
}