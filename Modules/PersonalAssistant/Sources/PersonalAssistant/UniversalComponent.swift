import SwiftUI
import Combine

/// # UniversalComponent Protocol
///
/// The revolutionary protocol that unifies ALL hierarchy levels in Bridge Template.
/// Whether you're building a Module, Submodule, Epic, Story, Feature, Task, Widget,
/// or any other component, they all conform to this single protocol.
///
/// ## Overview
///
/// UniversalComponent is the cornerstone of infinite recursive modularity. It provides:
/// - **Hierarchy Agnostic**: Works identically at any nesting level
/// - **Complete Lifecycle**: Full initialization, execution, and cleanup
/// - **Built-in CICD**: Automated testing and deployment at every level
/// - **Version Management**: Independent versioning for any component
/// - **Hot-Swappable**: Runtime replacement without restart
/// - **Self-Documenting**: Automatic documentation generation
///
/// ## Topics
///
/// ### Component Identity
/// - ``id``
/// - ``name``
/// - ``hierarchyLevel``
/// - ``version``
/// - ``icon``
///
/// ### Component Structure
/// - ``parent``
/// - ``children``
/// - ``dependencies``
/// - ``capabilities``
///
/// ### Component Interface
/// - ``view``
/// - ``configuration``
/// - ``state``
///
/// ### Lifecycle Management
/// - ``initialize()``
/// - ``execute()``
/// - ``suspend()``
/// - ``resume()``
/// - ``cleanup()``
/// - ``canUnload()``
///
/// ### Communication
/// - ``receiveMessage(_:)``
/// - ``sendMessage(_:to:)``
/// - ``broadcast(_:)``
///
/// ### CICD Integration
/// - ``test()``
/// - ``build()``
/// - ``deploy()``
/// - ``validate()``
///
/// ## Example
///
/// ```swift
/// // This same structure works for ANY hierarchy level
/// class MyFeature: UniversalComponent {
///     let id = UUID()
///     let name = "Advanced Search"
///     let hierarchyLevel = .feature
///     let version = ComponentVersion(1, 0, 0)
///     
///     // ... implement all requirements
/// }
/// ```
@MainActor
public protocol UniversalComponent: AnyObject, ObservableObject, Identifiable {
    
    // MARK: - Identity
    
    /// Unique identifier for this component
    var id: UUID { get }
    
    /// Human-readable name
    var name: String { get }
    
    /// The hierarchy level of this component
    var hierarchyLevel: HierarchyLevel { get }
    
    /// Component version with full semantic versioning
    var version: ComponentVersion { get }
    
    /// SF Symbol icon name
    var icon: String { get }
    
    /// Component description for documentation
    var description: String { get }
    
    // MARK: - Structure
    
    /// Parent component (nil for root components)
    var parent: (any UniversalComponent)? { get set }
    
    /// Child components at any hierarchy level
    var children: [any UniversalComponent] { get set }
    
    /// Component dependencies by ID
    var dependencies: [UUID] { get set }
    
    /// Capabilities this component provides
    var capabilities: [ComponentCapability] { get }
    
    // MARK: - Interface
    
    /// The SwiftUI view for this component
    var view: AnyView { get }
    
    /// Component configuration
    var configuration: ComponentConfiguration { get set }
    
    /// Runtime state management
    var state: ComponentState { get set }
    
    // MARK: - Lifecycle
    
    /// Initialize the component and its resources
    func initialize() async throws
    
    /// Execute the component's primary function
    func execute() async throws -> ComponentResult
    
    /// Suspend component operation
    func suspend() async throws
    
    /// Resume component operation
    func resume() async throws
    
    /// Clean up resources before removal
    func cleanup() async throws
    
    /// Check if component can be safely unloaded
    func canUnload() -> Bool
    
    // MARK: - Communication
    
    /// Receive a message from another component
    func receiveMessage(_ message: ComponentMessage) async throws
    
    /// Send a message to a specific component
    func sendMessage(_ message: ComponentMessage, to recipient: UUID) async throws
    
    /// Broadcast a message to all children
    func broadcast(_ message: ComponentMessage) async throws
    
    // MARK: - CICD
    
    /// Run component tests
    func test() async throws -> TestResult
    
    /// Build the component
    func build() async throws -> BuildArtifact
    
    /// Deploy the component
    func deploy(to environment: DeploymentEnvironment) async throws
    
    /// Validate component integrity
    func validate() async throws -> ValidationResult
    
    // MARK: - Metrics
    
    /// Component performance metrics
    var metrics: ComponentMetrics { get }
    
    /// Component health status
    var health: ComponentHealth { get }
}

// MARK: - Supporting Types

/// Hierarchy levels in the Bridge Template system
public enum HierarchyLevel: String, CaseIterable, Codable {
    case app = "App"
    case module = "Module"
    case submodule = "Submodule"
    case epic = "Epic"
    case story = "Story"
    case feature = "Feature"
    case component = "Component"
    case widget = "Widget"
    case task = "Task"
    case subtask = "Subtask"
    case microservice = "Microservice"
    case utility = "Utility"
    
    /// Color for visual representation
    public var color: Color {
        switch self {
        case .app: return .purple
        case .module: return .blue
        case .submodule: return .cyan
        case .epic: return .indigo
        case .story: return .green
        case .feature: return .orange
        case .component: return .pink
        case .widget: return .yellow
        case .task: return .red
        case .subtask: return .brown
        case .microservice: return .mint
        case .utility: return .gray
        }
    }
    
    /// Relative importance/size
    public var weight: Int {
        switch self {
        case .app: return 100
        case .module: return 90
        case .submodule: return 80
        case .epic: return 70
        case .story: return 60
        case .feature: return 50
        case .component: return 40
        case .widget: return 30
        case .task: return 20
        case .subtask: return 10
        case .microservice: return 25
        case .utility: return 15
        }
    }
}

/// Component version with semantic versioning
public struct ComponentVersion: Codable, Comparable, CustomStringConvertible, Hashable, Sendable {
    public let major: Int
    public let minor: Int
    public let patch: Int
    public let prerelease: String?
    public let build: String?
    
    public init(_ major: Int, _ minor: Int, _ patch: Int, 
                prerelease: String? = nil, build: String? = nil) {
        self.major = major
        self.minor = minor
        self.patch = patch
        self.prerelease = prerelease
        self.build = build
    }
    
    public var description: String {
        var version = "\(major).\(minor).\(patch)"
        if let pre = prerelease { version += "-\(pre)" }
        if let b = build { version += "+\(b)" }
        return version
    }
    
    public static func < (lhs: ComponentVersion, rhs: ComponentVersion) -> Bool {
        if lhs.major != rhs.major { return lhs.major < rhs.major }
        if lhs.minor != rhs.minor { return lhs.minor < rhs.minor }
        return lhs.patch < rhs.patch
    }
}

/// Component capability declaration
public struct ComponentCapability: Codable, Hashable {
    public let id: String
    public let name: String
    public let description: String
    public let version: String
    
    public init(id: String, name: String, description: String, version: String = "1.0.0") {
        self.id = id
        self.name = name
        self.description = description
        self.version = version
    }
}

/// Component configuration
public struct ComponentConfiguration: Codable {
    public var isEnabled: Bool = true
    public var settings: [String: AnyCodable] = [:]
    public var environment: [String: String] = [:]
    public var features: Set<String> = []
    public var permissions: Set<String> = []
    
    public init() {}
}

/// Component runtime state
public struct ComponentState: Codable {
    public var status: ComponentStatus = .uninitialized
    public var lastActivity: Date = Date()
    public var errorCount: Int = 0
    public var metadata: [String: AnyCodable] = [:]
    
    public init() {}
}

/// Component status
public enum ComponentStatus: String, Codable {
    case uninitialized = "Uninitialized"
    case initializing = "Initializing"
    case ready = "Ready"
    case executing = "Executing"
    case suspended = "Suspended"
    case error = "Error"
    case cleaning = "Cleaning"
}

/// Component message for communication
public struct ComponentMessage: Codable {
    public let id: UUID
    public let source: UUID
    public let destination: UUID?
    public let type: MessageType
    public let payload: [String: AnyCodable]
    public let timestamp: Date
    
    public init(source: UUID, destination: UUID? = nil, 
                type: MessageType, payload: [String: AnyCodable] = [:]) {
        self.id = UUID()
        self.source = source
        self.destination = destination
        self.type = type
        self.payload = payload
        self.timestamp = Date()
    }
    
    public enum MessageType: String, Codable {
        case command = "Command"
        case query = "Query"
        case response = "Response"
        case event = "Event"
        case notification = "Notification"
        case error = "Error"
    }
}

/// Component execution result
public struct ComponentResult: Codable {
    public let success: Bool
    public let output: AnyCodable?
    public let error: String?
    public let duration: TimeInterval
    public let metrics: [String: Double]
    
    public init(success: Bool, output: AnyCodable? = nil, 
                error: String? = nil, duration: TimeInterval, 
                metrics: [String: Double] = [:]) {
        self.success = success
        self.output = output
        self.error = error
        self.duration = duration
        self.metrics = metrics
    }
}

/// Test result
public struct TestResult: Codable {
    public let passed: Int
    public let failed: Int
    public let skipped: Int
    public let duration: TimeInterval
    public let coverage: Double
    public let failures: [TestFailure]
    
    public struct TestFailure: Codable {
        public let test: String
        public let reason: String
        public let file: String
        public let line: Int
    }
}

/// Build artifact
public struct BuildArtifact: Codable {
    public let id: UUID
    public let version: ComponentVersion
    public let path: String
    public let size: Int64
    public let checksum: String
    public let metadata: [String: AnyCodable]
    public let timestamp: Date
}

/// Deployment environment
public enum DeploymentEnvironment: String, Codable {
    case development = "Development"
    case staging = "Staging"
    case production = "Production"
    case testing = "Testing"
    case preview = "Preview"
}

/// Validation result
public struct ValidationResult: Codable {
    public let isValid: Bool
    public let errors: [ValidationError]
    public let warnings: [ValidationWarning]
    
    public struct ValidationError: Codable, Sendable {
        public let code: String
        public let message: String
        public let severity: Severity
        
        public enum Severity: String, Codable, Sendable {
            case critical = "Critical"
            case high = "High"
            case medium = "Medium"
            case low = "Low"
        }
    }
    
    public struct ValidationWarning: Codable {
        public let code: String
        public let message: String
    }
}

/// Component metrics
public struct ComponentMetrics: Codable {
    public var executionCount: Int = 0
    public var totalDuration: TimeInterval = 0
    public var averageDuration: TimeInterval { 
        executionCount > 0 ? totalDuration / Double(executionCount) : 0 
    }
    public var lastExecution: Date?
    public var memoryUsage: Int64 = 0
    public var cpuUsage: Double = 0
    public var customMetrics: [String: Double] = [:]
}

/// Component health
public struct ComponentHealth: Codable {
    public var status: HealthStatus = .unknown
    public var lastCheck: Date = Date()
    public var issues: [HealthIssue] = []
    
    public enum HealthStatus: String, Codable {
        case healthy = "Healthy"
        case degraded = "Degraded"
        case unhealthy = "Unhealthy"
        case unknown = "Unknown"
    }
    
    public struct HealthIssue: Codable {
        public let type: String
        public let description: String
        public let since: Date
    }
}

// MARK: - Type-Erased Codable

/// Type-erased Codable for heterogeneous dictionaries
public struct AnyCodable: Codable {
    public let value: Any
    
    public init(_ value: Any) {
        self.value = value
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let int = try? container.decode(Int.self) {
            value = int
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else if let string = try? container.decode(String.self) {
            value = string
        } else if let bool = try? container.decode(Bool.self) {
            value = bool
        } else if let array = try? container.decode([AnyCodable].self) {
            value = array.map { $0.value }
        } else if let dict = try? container.decode([String: AnyCodable].self) {
            value = dict.mapValues { $0.value }
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unable to decode value")
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch value {
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        case let string as String:
            try container.encode(string)
        case let bool as Bool:
            try container.encode(bool)
        case let array as [Any]:
            try container.encode(array.map { AnyCodable($0) })
        case let dict as [String: Any]:
            try container.encode(dict.mapValues { AnyCodable($0) })
        default:
            throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "Unable to encode value"))
        }
    }
}