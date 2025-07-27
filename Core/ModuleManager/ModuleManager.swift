import SwiftUI
import Combine

/// # ModuleManager
///
/// The central engine for managing hot-swappable modules in the Bridge Template system.
/// Handles module lifecycle, dependency resolution, version management, and cross-module
/// communication.
///
/// ## Overview
///
/// ModuleManager is the heart of Bridge Template's modular architecture. It enables:
/// - **Hot-swapping**: Replace modules at runtime without restart
/// - **Dependency management**: Automatic resolution and validation
/// - **Version control**: Load specific versions of modules
/// - **Message routing**: Cross-module communication
/// - **Lifecycle management**: Initialize and cleanup modules properly
///
/// ## Topics
///
/// ### Module Loading
/// - ``loadModule(identifier:version:)``
/// - ``unloadModule(identifier:)``
/// - ``reloadModule(identifier:)``
/// - ``updateModule(identifier:to:)``
///
/// ### Module Discovery
/// - ``loadedModules``
/// - ``availableModules``
/// - ``isModuleLoaded(_:)``
/// - ``getModule(_:)``
///
/// ### Communication
/// - ``sendMessage(_:)``
/// - ``broadcastMessage(_:)``
///
/// ### Dependency Management
/// - ``resolveDependencies(for:)``
/// - ``checkCompatibility(module:with:)``
///
/// ## Version History
/// - v2.0.0: Complete rewrite for infinite modularity
/// - v1.0.0: Initial implementation
///
/// ## Usage
/// ```swift
/// let manager = ModuleManager()
/// 
/// // Load a module
/// try await manager.loadModule(identifier: "com.bridge.dashboard", version: "1.5.2")
/// 
/// // Send a message
/// let message = ModuleMessage(
///     source: "com.bridge.app",
///     destination: "com.bridge.dashboard",
///     type: "refresh"
/// )
/// try await manager.sendMessage(message)
/// 
/// // Hot-swap to a different version
/// try await manager.updateModule(identifier: "com.bridge.dashboard", to: "1.5.3")
/// ```
@MainActor
public class ModuleManager: ObservableObject {
    
    /// Currently loaded modules indexed by identifier
    ///
    /// This dictionary maintains references to all active modules in the system.
    /// Modules are keyed by their unique identifiers for fast lookup.
    @Published public private(set) var loadedModules: [String: any BridgeModule] = [:]
    
    /// Available modules that can be loaded
    ///
    /// Contains metadata about all modules discovered in the system,
    /// including those not currently loaded.
    @Published public private(set) var availableModules: [ModuleMetadata] = []
    
    /// Module loading state for UI feedback
    @Published public private(set) var isLoading: [String: Bool] = [:]
    
    /// Active message queue for cross-module communication
    private var messageQueue: [ModuleMessage] = []
    
    /// Cancellables for Combine subscriptions
    private var cancellables = Set<AnyCancellable>()
    
    /// Initialize the ModuleManager
    ///
    /// Sets up the module system and discovers available modules.
    public init() {
        // Discovery happens on demand
    }
    
    /// Discover and prepare available modules
    public func discoverAndLoadModules() async {
        await discoverAvailableModules()
    }
    
    /// Load a module into the system
    ///
    /// Loads the specified module and all its dependencies. If a version
    /// is not specified, loads the latest available version.
    ///
    /// - Parameters:
    ///   - identifier: Unique module identifier
    ///   - version: Specific version to load (optional)
    /// - Returns: The loaded module instance
    /// - Throws: ModuleError if loading fails
    ///
    /// ## Example
    /// ```swift
    /// let dashboard = try await manager.loadModule(
    ///     identifier: "com.bridge.dashboard",
    ///     version: "1.5.2"
    /// )
    /// ```
    public func loadModule(identifier: String, version: String? = nil) async throws -> any BridgeModule {
        // Check if already loaded
        if let existing = loadedModules[identifier] {
            if let version = version, existing.version.description != version {
                // Version mismatch - need to hot-swap
                return try await updateModule(identifier: identifier, to: version)
            }
            return existing
        }
        
        // Set loading state
        isLoading[identifier] = true
        defer { isLoading[identifier] = false }
        
        // Find module metadata
        guard let metadata = findModuleMetadata(identifier: identifier, version: version) else {
            throw ModuleError.initializationFailed("Module '\(identifier)' not found")
        }
        
        // Load dependencies first
        try await loadDependencies(for: metadata)
        
        // Create module instance
        let module = try await createModuleInstance(from: metadata)
        
        // Initialize module
        try await module.initialize()
        
        // Register module
        loadedModules[identifier] = module
        
        // Load sub-modules
        for (subId, subModule) in module.subModules {
            loadedModules[subId] = subModule
        }
        
        print("✅ Loaded module: \(identifier) v\(module.version)")
        return module
    }
    
    /// Unload a module from the system
    ///
    /// Safely unloads a module after checking dependencies and
    /// allowing it to clean up resources.
    ///
    /// - Parameter identifier: Module identifier to unload
    /// - Throws: ModuleError if unloading fails
    ///
    /// ## Example
    /// ```swift
    /// try await manager.unloadModule(identifier: "com.bridge.terminal")
    /// ```
    public func unloadModule(identifier: String) async throws {
        guard let module = loadedModules[identifier] else {
            throw ModuleError.initializationFailed("Module '\(identifier)' not loaded")
        }
        
        // Check if module can be unloaded
        guard module.canUnload() else {
            throw ModuleError.initializationFailed("Module '\(identifier)' cannot be unloaded")
        }
        
        // Check if other modules depend on this one
        try checkDependents(for: identifier)
        
        // Cleanup module
        await module.cleanup()
        
        // Unload sub-modules first
        for (subId, _) in module.subModules {
            loadedModules.removeValue(forKey: subId)
        }
        
        // Remove from loaded modules
        loadedModules.removeValue(forKey: identifier)
        
        print("🗑️ Unloaded module: \(identifier)")
    }
    
    /// Reload a module without changing version
    ///
    /// Useful for applying configuration changes or recovering
    /// from errors without changing the module version.
    ///
    /// - Parameter identifier: Module identifier to reload
    /// - Returns: The reloaded module instance
    /// - Throws: ModuleError if reloading fails
    public func reloadModule(identifier: String) async throws -> any BridgeModule {
        guard let currentModule = loadedModules[identifier] else {
            throw ModuleError.initializationFailed("Module '\(identifier)' not loaded")
        }
        
        let version = currentModule.version.description
        try await unloadModule(identifier: identifier)
        return try await loadModule(identifier: identifier, version: version)
    }
    
    /// Update a module to a different version (hot-swap)
    ///
    /// Performs a hot-swap operation, replacing the current module
    /// with a different version without affecting other modules.
    ///
    /// - Parameters:
    ///   - identifier: Module identifier to update
    ///   - version: Target version
    /// - Returns: The updated module instance
    /// - Throws: ModuleError if update fails
    ///
    /// ## Example
    /// ```swift
    /// // Upgrade to newer version
    /// let updated = try await manager.updateModule(
    ///     identifier: "com.bridge.dashboard",
    ///     to: "1.6.0"
    /// )
    /// 
    /// // Rollback to previous version
    /// let rolledBack = try await manager.updateModule(
    ///     identifier: "com.bridge.dashboard",
    ///     to: "1.5.2"
    /// )
    /// ```
    public func updateModule(identifier: String, to version: String) async throws -> any BridgeModule {
        print("🔄 Hot-swapping \(identifier) to version \(version)")
        
        // Unload current version
        if loadedModules[identifier] != nil {
            try await unloadModule(identifier: identifier)
        }
        
        // Load new version
        return try await loadModule(identifier: identifier, version: version)
    }
    
    /// Send a message between modules
    ///
    /// Routes messages between modules asynchronously. Messages are
    /// delivered even if modules are hot-swapped during delivery.
    ///
    /// - Parameter message: Message to send
    /// - Throws: ModuleError if delivery fails
    ///
    /// ## Example
    /// ```swift
    /// let message = ModuleMessage(
    ///     source: "com.bridge.projects",
    ///     destination: "com.bridge.dashboard",
    ///     type: "projectUpdated",
    ///     payload: ["projectId": "12345"]
    /// )
    /// 
    /// try await manager.sendMessage(message)
    /// ```
    public func sendMessage(_ message: ModuleMessage) async throws {
        guard let destination = loadedModules[message.destination] else {
            throw ModuleError.messageDeliveryFailed("Destination module '\(message.destination)' not loaded")
        }
        
        try await destination.receiveMessage(message)
        print("📬 Delivered message from \(message.source) to \(message.destination)")
    }
    
    /// Broadcast a message to all loaded modules
    ///
    /// Useful for system-wide events like theme changes or
    /// shutdown notifications.
    ///
    /// - Parameter message: Message to broadcast
    public func broadcastMessage(_ message: ModuleMessage) async {
        await withTaskGroup(of: Void.self) { group in
            for (id, module) in loadedModules {
                group.addTask {
                    do {
                        var broadcastMessage = message
                        broadcastMessage = ModuleMessage(
                            source: message.source,
                            destination: id,
                            type: message.type,
                            payload: message.payload
                        )
                        try await module.receiveMessage(broadcastMessage)
                    } catch {
                        print("⚠️ Failed to deliver broadcast to \(id): \(error)")
                    }
                }
            }
        }
    }
    
    /// Check if a module is currently loaded
    ///
    /// - Parameter identifier: Module identifier to check
    /// - Returns: true if the module is loaded
    public func isModuleLoaded(_ identifier: String) -> Bool {
        loadedModules[identifier] != nil
    }
    
    /// Get a loaded module by identifier
    ///
    /// - Parameter identifier: Module identifier
    /// - Returns: The module instance or nil if not loaded
    public func getModule(_ identifier: String) -> (any BridgeModule)? {
        loadedModules[identifier]
    }
    
    // MARK: - Private Methods
    
    /// Discover available modules in the system
    private func discoverAvailableModules() async {
        // In production, this would scan the Modules directory
        // For now, we'll hardcode some example modules
        availableModules = [
            ModuleMetadata(
                identifier: "com.bridge.dashboard",
                name: "Dashboard",
                versions: ["1.5.0", "1.5.1", "1.5.2", "1.6.0-beta"],
                dependencies: []
            ),
            ModuleMetadata(
                identifier: "com.bridge.projects",
                name: "Projects",
                versions: ["1.8.0", "1.8.1"],
                dependencies: ["com.bridge.dashboard"]
            ),
            ModuleMetadata(
                identifier: "com.bridge.terminal",
                name: "Terminal",
                versions: ["1.3.0"], // Real version with Claude integration and auto-permissions
                dependencies: [],
                capabilities: [
                    "Native macOS Terminal with PTY support",
                    "Claude Code integration with automated onboarding",
                    "Auto-permission system with keychain security",
                    "Multi-session support with tabs and management",
                    "Full ANSI color and escape sequence support",
                    "Unattended execution for CI/CD workflows",
                    "Hot-swappable for runtime updates"
                ]
            )
        ]
    }
    
    /// Find module metadata
    private func findModuleMetadata(identifier: String, version: String?) -> ModuleMetadata? {
        guard let metadata = availableModules.first(where: { $0.identifier == identifier }) else {
            return nil
        }
        
        // If no version specified, use latest
        if version == nil {
            return metadata
        }
        
        // Check if requested version exists
        if let version = version, metadata.versions.contains(version) {
            return metadata
        }
        
        return nil
    }
    
    /// Load dependencies for a module
    private func loadDependencies(for metadata: ModuleMetadata) async throws {
        for dependency in metadata.dependencies {
            if !isModuleLoaded(dependency) {
                _ = try await loadModule(identifier: dependency)
            }
        }
    }
    
    /// Create module instance from metadata
    private func createModuleInstance(from metadata: ModuleMetadata) async throws -> any BridgeModule {
        // NOTE: In a real implementation with proper module loading,
        // this would use the actual Terminal module from the Terminal package.
        // For now, we use mocks but the infrastructure is ready for real modules.
        switch metadata.identifier {
        case "com.bridge.dashboard":
            return MockDashboardModule()
        case "com.bridge.projects":
            return MockProjectsModule()
        case "com.bridge.terminal":
            // In production: return TerminalModule() from Terminal package
            return MockTerminalModule()
        default:
            throw ModuleError.initializationFailed("Unknown module: \(metadata.identifier)")
        }
    }
    
    /// Check if any loaded modules depend on the given module
    private func checkDependents(for identifier: String) throws {
        for (loadedId, loadedModule) in loadedModules {
            if loadedModule.dependencies.contains(identifier) {
                throw ModuleError.initializationFailed(
                    "Cannot unload '\(identifier)' - required by '\(loadedId)'"
                )
            }
        }
    }
}

/// # ModuleMetadata
///
/// Metadata about an available module, used for discovery and loading.
///
/// ## Topics
///
/// ### Properties
/// - ``identifier``
/// - ``name``
/// - ``versions``
/// - ``dependencies``
/// - ``capabilities``
public struct ModuleMetadata {
    
    /// Unique module identifier
    public let identifier: String
    
    /// Display name
    public let name: String
    
    /// Available versions
    public let versions: [String]
    
    /// Required dependencies
    public let dependencies: [String]
    
    /// Module capabilities (optional)
    public let capabilities: [String]?
    
    /// Initialize ModuleMetadata
    public init(identifier: String, name: String, versions: [String], dependencies: [String], capabilities: [String]? = nil) {
        self.identifier = identifier
        self.name = name
        self.versions = versions
        self.dependencies = dependencies
        self.capabilities = capabilities
    }
}