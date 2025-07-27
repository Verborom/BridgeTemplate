import Testing
@testable import UniversalTemplate
import SwiftUI

/// # UniversalComponent Tests
///
/// Comprehensive test suite for the UniversalTemplate system
@Suite("UniversalComponent Tests")
struct UniversalComponentTests {
    
    // MARK: - Component Creation Tests
    
    @Test("Create basic component")
    @MainActor
    func testBasicComponentCreation() async throws {
        let component = TestComponent()
        
        #expect(component.name == "Test Component")
        #expect(component.hierarchyLevel == .component)
        #expect(component.version == ComponentVersion(1, 0, 0))
    }
    
    @Test("Component hierarchy levels")
    @MainActor
    func testHierarchyLevels() async throws {
        for level in HierarchyLevel.allCases {
            let component = createComponent(at: level)
            #expect(component.hierarchyLevel == level)
        }
    }
    
    // MARK: - Lifecycle Tests
    
    @Test("Component initialization")
    @MainActor
    func testComponentInitialization() async throws {
        let component = TestComponent()
        
        #expect(component.state.status == .uninitialized)
        
        try await component.initialize()
        
        #expect(component.state.status == .ready)
    }
    
    @Test("Component execution")
    @MainActor
    func testComponentExecution() async throws {
        let component = TestComponent()
        try await component.initialize()
        
        let result = try await component.execute()
        
        #expect(result.success == true)
        #expect(component.metrics.executionCount == 1)
    }
    
    @Test("Component suspension and resumption")
    @MainActor
    func testComponentSuspensionResumption() async throws {
        let component = TestComponent()
        try await component.initialize()
        
        try await component.suspend()
        #expect(component.state.status == .suspended)
        
        try await component.resume()
        #expect(component.state.status == .ready)
    }
    
    // MARK: - Hierarchy Management Tests
    
    @Test("Parent-child relationships")
    @MainActor
    func testParentChildRelationships() async throws {
        let parent = createComponent(at: .module)
        let child = createComponent(at: .feature)
        
        let manager = HierarchyManager()
        try await manager.addChild(child, to: parent)
        
        #expect(child.parent?.id == parent.id)
        #expect(parent.children.contains { $0.id == child.id })
    }
    
    @Test("Hierarchy validation")
    @MainActor
    func testHierarchyValidation() async throws {
        let module = createComponent(at: .module)
        let app = createComponent(at: .app)
        
        let manager = HierarchyManager()
        
        // Should fail - can't add higher-level component as child
        await #expect(throws: HierarchyError.self) {
            try await manager.addChild(app, to: module)
        }
    }
    
    // MARK: - Component Factory Tests
    
    @Test("Factory component creation")
    @MainActor
    func testFactoryCreation() async throws {
        let factory = ComponentFactory.shared
        
        let config = ComponentCreationConfig(
            name: "Test Feature",
            hierarchyLevel: .feature,
            version: ComponentVersion(1, 2, 3)
        )
        
        let component = try await factory.create(from: config)
        
        #expect(component.name == "Test Feature")
        #expect(component.hierarchyLevel == .feature)
        #expect(component.version == ComponentVersion(1, 2, 3))
    }
    
    @Test("Batch component creation")
    @MainActor
    func testBatchCreation() async throws {
        let factory = ComponentFactory.shared
        
        let configs = (1...5).map { i in
            ComponentCreationConfig(
                name: "Component \(i)",
                hierarchyLevel: .component,
                version: ComponentVersion(1, 0, 0)
            )
        }
        
        let batchConfig = BatchCreationConfig(components: configs)
        let components = try await factory.createBatch(from: batchConfig)
        
        #expect(components.count == 5)
    }
    
    // MARK: - Version Management Tests
    
    @Test("Version compatibility")
    func testVersionCompatibility() {
        let manager = VersionManager.shared
        
        let v1 = ComponentVersion(1, 0, 0)
        let v1_1 = ComponentVersion(1, 1, 0)
        let v2 = ComponentVersion(2, 0, 0)
        
        #expect(manager.areCompatible(current: v1, target: v1_1) == true)
        #expect(manager.areCompatible(current: v1, target: v2) == true)
        #expect(manager.areCompatible(current: v2, target: v1) == false)
    }
    
    @Test("Version comparison")
    func testVersionComparison() {
        let v1 = ComponentVersion(1, 0, 0)
        let v1_1 = ComponentVersion(1, 1, 0)
        let v1_1_1 = ComponentVersion(1, 1, 1)
        
        #expect(v1 < v1_1)
        #expect(v1_1 < v1_1_1)
        #expect(v1 < v1_1_1)
    }
    
    // MARK: - Communication Tests
    
    @Test("Component messaging")
    @MainActor
    func testComponentMessaging() async throws {
        let sender = TestComponent()
        let receiver = TestComponent()
        
        let message = ComponentMessage(
            source: sender.id,
            destination: receiver.id,
            type: .command,
            payload: ["command": AnyCodable("test")]
        )
        
        try await receiver.receiveMessage(message)
        
        // Verify message was handled
        #expect(receiver.lastReceivedMessage?.id == message.id)
    }
    
    // MARK: - Performance Tests
    
    @Test("Component creation performance")
    @MainActor
    func testCreationPerformance() async throws {
        let startTime = Date()
        
        for _ in 0..<100 {
            _ = TestComponent()
        }
        
        let duration = Date().timeIntervalSince(startTime)
        
        // Should create 100 components in under 1 second
        #expect(duration < 1.0)
    }
    
    // MARK: - Helper Methods
    
    @MainActor
    private func createComponent(at level: HierarchyLevel) -> any UniversalComponent {
        let component = TestComponent()
        component.hierarchyLevel = level
        return component
    }
}

// MARK: - Test Component

@MainActor
private class TestComponent: BaseComponent {
    var lastReceivedMessage: ComponentMessage?
    
    override init() {
        super.init()
        self.name = "Test Component"
        self.hierarchyLevel = .component
        self.version = ComponentVersion(1, 0, 0)
    }
    
    override func handleCustomMessage(_ message: ComponentMessage) async throws {
        lastReceivedMessage = message
    }
}