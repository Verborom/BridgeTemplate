import SwiftUI

/// # BridgeModule Protocol
///
/// The core protocol that defines the interface for all hot-swappable modules
/// in the Bridge Template system. This protocol enables infinite recursive modularity,
/// independent versioning, and runtime module management.
///
/// ## Overview
/// 
/// BridgeModule is the foundation of the Bridge Template architecture. Every module,
/// whether it's a top-level feature like Dashboard or a deeply nested sub-module
/// like StatsWidget, must conform to this protocol. This enables:
///
/// - **Hot-swapping**: Replace modules at runtime without app restart
/// - **Independent versioning**: Each module has its own version lifecycle
/// - **Recursive nesting**: Modules can contain other modules infinitely
/// - **Cross-module communication**: Standardized messaging interface
/// - **Automated documentation**: Comments generate beautiful docs via DocC
///
/// ## Topics
///
/// ### Module Identity
/// - ``id``
/// - ``displayName``
/// - ``icon``
/// - ``version``
///
/// ### Module Interface
/// - ``view``
/// - ``subModules``
///
/// ### Lifecycle Management
/// - ``initialize()``
/// - ``cleanup()``
/// - ``canUnload()``
///
/// ### Communication
/// - ``receiveMessage(_:)``
/// - ``dependencies``
///
/// ## Version History
/// - v2.0.0: Complete redesign for infinite modularity
/// - v1.0.0: Initial protocol definition
///
/// ## Usage
/// ```swift
/// class DashboardModule: BridgeModule {
///     let id = "com.bridge.dashboard"
///     let displayName = "Dashboard"
///     let icon = "square.grid.2x2"
///     let version = ModuleVersion(major: 1, minor: 5, patch: 2)
///     
///     var view: AnyView {
///         AnyView(DashboardView())
///     }
///     
///     func initialize() {
///         // Set up module resources
///     }
/// }
/// ```
public protocol BridgeModule: ObservableObject {
    
    /// The unique identifier for this module
    ///
    /// This identifier is used throughout the system for module registration,
    /// dependency management, and cross-module communication. It should follow
    /// reverse-DNS notation (e.g., "com.bridge.dashboard").
    ///
    /// - Important: This value must never change once a module is deployed,
    ///   as other modules may depend on it.
    var id: String { get }
    
    /// Human-readable display name for the module
    ///
    /// This name appears in the user interface, including navigation sidebars,
    /// module selection screens, and debugging tools. Keep it concise but
    /// descriptive.
    ///
    /// - Note: Unlike the id, this can be localized and changed between versions.
    var displayName: String { get }
    
    /// SF Symbol icon name for the module
    ///
    /// Used throughout the interface to visually identify this module.
    /// Choose an icon that clearly represents the module's purpose.
    ///
    /// - Tip: Use SF Symbols 4+ for best results with gradients and colors.
    var icon: String { get }
    
    /// The current version of this module
    ///
    /// Each module maintains its own version number, enabling independent
    /// updates and hot-swapping. The version is used for dependency
    /// resolution and compatibility checking.
    ///
    /// - SeeAlso: ``ModuleVersion``
    var version: ModuleVersion { get }
    
    /// The main SwiftUI view for this module
    ///
    /// This property returns the primary interface that will be displayed
    /// when the module is active. The view should be self-contained and
    /// handle its own state management.
    ///
    /// - Returns: The module's main view wrapped in AnyView for type erasure
    var view: AnyView { get }
    
    /// Sub-modules contained within this module
    ///
    /// Enables infinite recursive modularity. Each module can contain any
    /// number of sub-modules, which can themselves contain sub-modules.
    /// This creates a tree structure of arbitrary depth.
    ///
    /// - Returns: Dictionary mapping module IDs to module instances
    var subModules: [String: any BridgeModule] { get }
    
    /// Dependencies required by this module
    ///
    /// Lists other modules that must be loaded before this module can
    /// function. The ModuleManager uses this to ensure proper load order
    /// and prevent dependency conflicts.
    ///
    /// - Returns: Array of module IDs this module depends on
    var dependencies: [String] { get }
    
    /// Initialize module resources and state
    ///
    /// Called when the module is first loaded into memory. Use this to:
    /// - Set up data connections
    /// - Initialize state
    /// - Register for notifications
    /// - Load saved preferences
    ///
    /// - Throws: ModuleError if initialization fails
    func initialize() async throws
    
    /// Clean up module resources before unloading
    ///
    /// Called before the module is removed from memory. Use this to:
    /// - Save any unsaved state
    /// - Close data connections
    /// - Unregister notifications
    /// - Release resources
    ///
    /// - Important: This method must complete within 5 seconds
    func cleanup() async
    
    /// Check if the module can be safely unloaded
    ///
    /// The ModuleManager calls this before attempting to unload a module.
    /// Return false if the module has unsaved changes or is performing
    /// critical operations.
    ///
    /// - Returns: true if the module can be unloaded, false otherwise
    func canUnload() -> Bool
    
    /// Receive a message from another module
    ///
    /// Enables cross-module communication. Messages are delivered
    /// asynchronously and should be processed without blocking.
    ///
    /// - Parameter message: The message to process
    /// - Throws: ModuleError if the message cannot be processed
    func receiveMessage(_ message: ModuleMessage) async throws
}

/// # ModuleVersion
///
/// Represents the semantic version of a module, enabling independent
/// versioning and compatibility checking across the module ecosystem.
///
/// ## Overview
///
/// Each module maintains its own version number following semantic
/// versioning principles. This enables:
/// - Independent module updates
/// - Dependency compatibility checking
/// - Version rollback capabilities
/// - Clear change communication
///
/// ## Topics
///
/// ### Version Components
/// - ``major``
/// - ``minor``
/// - ``patch``
/// - ``prerelease``
/// - ``build``
///
/// ## Version History
/// - v1.0.0: Initial implementation
///
/// ## Usage
/// ```swift
/// let version = ModuleVersion(major: 1, minor: 5, patch: 2)
/// print(version) // "1.5.2"
/// 
/// let beta = ModuleVersion(
///     major: 2, 
///     minor: 0, 
///     patch: 0, 
///     prerelease: "beta.1"
/// )
/// print(beta) // "2.0.0-beta.1"
/// ```
public struct ModuleVersion: Codable, Comparable, CustomStringConvertible {
    
    /// Major version number
    ///
    /// Increment when making incompatible API changes.
    public let major: Int
    
    /// Minor version number
    ///
    /// Increment when adding functionality in a backwards-compatible manner.
    public let minor: Int
    
    /// Patch version number
    ///
    /// Increment when making backwards-compatible bug fixes.
    public let patch: Int
    
    /// Prerelease version identifier
    ///
    /// Optional string for alpha, beta, or release candidate versions.
    public let prerelease: String?
    
    /// Build metadata
    ///
    /// Optional build information that doesn't affect version precedence.
    public let build: String?
    
    /// Initialize a new module version
    ///
    /// - Parameters:
    ///   - major: Major version number
    ///   - minor: Minor version number
    ///   - patch: Patch version number
    ///   - prerelease: Optional prerelease identifier
    ///   - build: Optional build metadata
    public init(major: Int, minor: Int, patch: Int, prerelease: String? = nil, build: String? = nil) {
        self.major = major
        self.minor = minor
        self.patch = patch
        self.prerelease = prerelease
        self.build = build
    }
    
    /// String representation of the version
    ///
    /// Formats the version according to semantic versioning specification.
    public var description: String {
        var result = "\(major).\(minor).\(patch)"
        if let prerelease = prerelease {
            result += "-\(prerelease)"
        }
        if let build = build {
            result += "+\(build)"
        }
        return result
    }
    
    /// Compare two versions for ordering
    public static func < (lhs: ModuleVersion, rhs: ModuleVersion) -> Bool {
        if lhs.major != rhs.major { return lhs.major < rhs.major }
        if lhs.minor != rhs.minor { return lhs.minor < rhs.minor }
        if lhs.patch != rhs.patch { return lhs.patch < rhs.patch }
        
        // Prerelease versions have lower precedence
        if lhs.prerelease != nil && rhs.prerelease == nil { return true }
        if lhs.prerelease == nil && rhs.prerelease != nil { return false }
        
        return false
    }
}

/// # ModuleMessage
///
/// Represents a message sent between modules for cross-module communication.
///
/// ## Overview
///
/// ModuleMessage enables decoupled communication between modules without
/// direct dependencies. Messages are delivered asynchronously through the
/// ModuleManager.
///
/// ## Topics
///
/// ### Message Properties
/// - ``id``
/// - ``source``
/// - ``destination``
/// - ``type``
/// - ``payload``
/// - ``timestamp``
///
/// ## Usage
/// ```swift
/// let message = ModuleMessage(
///     source: "com.bridge.dashboard",
///     destination: "com.bridge.projects",
///     type: "refreshData",
///     payload: ["projectId": "12345"]
/// )
/// 
/// try await moduleManager.sendMessage(message)
/// ```
public struct ModuleMessage: Codable {
    
    /// Unique identifier for this message
    public let id: UUID
    
    /// Module ID that sent this message
    public let source: String
    
    /// Module ID that should receive this message
    public let destination: String
    
    /// Message type identifier
    ///
    /// Used by receiving modules to determine how to process the message.
    public let type: String
    
    /// Message payload
    ///
    /// Contains the actual data being communicated between modules.
    /// Uses a dictionary with String values for Codable compatibility.
    public let payload: [String: String]
    
    /// Timestamp when the message was created
    public let timestamp: Date
    
    /// Initialize a new module message
    public init(source: String, destination: String, type: String, payload: [String: String] = [:]) {
        self.id = UUID()
        self.source = source
        self.destination = destination
        self.type = type
        self.payload = payload
        self.timestamp = Date()
    }
}

/// # ModuleError
///
/// Errors that can occur during module operations.
///
/// ## Topics
///
/// ### Error Cases
/// - ``dependencyMissing(_:)``
/// - ``initializationFailed(_:)``
/// - ``incompatibleVersion(_:required:)``
/// - ``circularDependency(_:)``
/// - ``messageDeliveryFailed(_:)``
public enum ModuleError: LocalizedError {
    
    /// A required dependency is not loaded
    case dependencyMissing(String)
    
    /// Module initialization failed
    case initializationFailed(String)
    
    /// Module version is incompatible
    case incompatibleVersion(String, required: String)
    
    /// Circular dependency detected
    case circularDependency([String])
    
    /// Message delivery failed
    case messageDeliveryFailed(String)
    
    /// Human-readable error description
    public var errorDescription: String? {
        switch self {
        case .dependencyMissing(let id):
            return "Required dependency '\(id)' is not loaded"
        case .initializationFailed(let reason):
            return "Module initialization failed: \(reason)"
        case .incompatibleVersion(let actual, let required):
            return "Module version \(actual) is incompatible, requires \(required)"
        case .circularDependency(let chain):
            return "Circular dependency detected: \(chain.joined(separator: " -> "))"
        case .messageDeliveryFailed(let reason):
            return "Message delivery failed: \(reason)"
        }
    }
}