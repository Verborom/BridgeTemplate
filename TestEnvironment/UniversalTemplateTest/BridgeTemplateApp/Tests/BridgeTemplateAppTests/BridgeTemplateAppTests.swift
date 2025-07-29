import XCTest
@testable import BridgeTemplateApp
import UniversalTemplate

@MainActor
final class BridgeTemplateAppTests: XCTestCase {
    
    func testComponentCreation() async throws {
        let component = BridgeTemplateApp()
        
        XCTAssertEqual(component.name, "BridgeTemplateApp")
        XCTAssertEqual(component.hierarchyLevel, .app)
    }
    
    func testComponentExecution() async throws {
        let component = BridgeTemplateApp()
        
        let result = try await component.execute()
        
        XCTAssertTrue(result.success)
    }
}