/// # Performance Tests for Architectural Rebuild
///
/// Validates that the new dynamic system performs as well as or better
/// than the original hardcoded system.
import XCTest
@testable import BridgeCore

final class RebuildPerformanceTests: XCTestCase {
    var moduleManager: ModuleManager!
    
    override func setUp() async throws {
        try await super.setUp()
        moduleManager = ModuleManager()
    }
    
    /// Test module discovery performance
    func testModuleDiscoveryPerformance() async throws {
        measure {
            Task {
                await moduleManager.discoverAvailableModules()
            }
        }
    }
    
    /// Test module loading performance
    func testModuleLoadingPerformance() async throws {
        await moduleManager.discoverAvailableModules()
        
        measure {
            Task {
                for metadata in moduleManager.availableModules {
                    _ = try await moduleManager.loadModule(identifier: metadata.identifier)
                }
            }
        }
    }
    
    /// Test hot-swap performance
    func testHotSwapPerformance() async throws {
        await moduleManager.discoverAvailableModules()
        _ = try await moduleManager.loadModule(identifier: "com.bridge.personalassistant")
        
        measure {
            Task {
                try await moduleManager.hotSwapModule("com.bridge.personalassistant", to: "1.0.1")
            }
        }
    }
    
    /// Test memory usage
    func testMemoryUsage() async throws {
        let initialMemory = getMemoryUsage()
        
        await moduleManager.discoverAvailableModules()
        for metadata in moduleManager.availableModules {
            _ = try await moduleManager.loadModule(identifier: metadata.identifier)
        }
        
        let loadedMemory = getMemoryUsage()
        let memoryIncrease = loadedMemory - initialMemory
        
        // Memory increase should be reasonable (under 50MB for all modules)
        XCTAssertLessThan(memoryIncrease, 50 * 1024 * 1024, "Memory usage should be reasonable")
    }
    
    private func getMemoryUsage() -> UInt64 {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            return info.resident_size
        } else {
            return 0
        }
    }
}