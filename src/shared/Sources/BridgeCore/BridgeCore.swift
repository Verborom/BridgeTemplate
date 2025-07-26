import Foundation

/// BridgeCore - Shared functionality for Bridge Template
public struct BridgeCore {
    public static let version = "1.0.0"
    
    public init() {}
    
    /// Shared greeting function
    public func greeting() -> String {
        return "Welcome to Bridge Template v\(BridgeCore.version)"
    }
}

// MARK: - Core Protocols

/// Base protocol for Bridge modules
public protocol BridgeModule {
    /// Unique identifier for the module
    var identifier: String { get }
    
    /// Current version of the module
    var version: String { get }
    
    /// Module dependencies
    var dependencies: [String] { get }
    
    /// Initialize the module
    func initialize() throws
    
    /// Cleanup module resources
    func teardown()
}

// MARK: - Core Models

/// Platform type enumeration
public enum Platform {
    case macOS
    case iOS
    
    public var name: String {
        switch self {
        case .macOS: return "macOS"
        case .iOS: return "iOS"
        }
    }
}

/// Configuration for modules
public struct ModuleConfiguration {
    public let platform: Platform
    public let environment: Environment
    public let settings: [String: Any]
    
    public enum Environment {
        case development
        case staging
        case production
    }
    
    public init(platform: Platform, environment: Environment = .development, settings: [String: Any] = [:]) {
        self.platform = platform
        self.environment = environment
        self.settings = settings
    }
}