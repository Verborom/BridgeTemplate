import SwiftUI
import Combine

/// # BaseComponent
///
/// The abstract base implementation of UniversalComponent that provides sensible
/// defaults and common functionality for all hierarchy levels. Components should
/// inherit from this class rather than implementing UniversalComponent directly.
///
/// ## Overview
///
/// BaseComponent handles the boilerplate implementation of UniversalComponent,
/// allowing derived classes to focus on their specific functionality. It provides:
///
/// - **Default Implementations**: Sensible defaults for all protocol requirements
/// - **State Management**: Built-in state and configuration handling
/// - **Message Routing**: Automatic message propagation to children
/// - **Lifecycle Hooks**: Override points for customization
/// - **Metric Collection**: Automatic performance tracking
///
/// ## Usage
///
/// ```swift
/// class MyFeature: BaseComponent {
///     override init() {
///         super.init()
///         self.name = "My Amazing Feature"
///         self.hierarchyLevel = .feature
///         self.icon = "star.fill"
///     }
///     
///     override func createView() -> AnyView {
///         AnyView(MyFeatureView())
///     }
///     
///     override func performExecution() async throws -> ComponentResult {
///         // Feature-specific logic here
///         return ComponentResult(success: true, duration: 0.1)
///     }
/// }
/// ```
@MainActor
open class BaseComponent: UniversalComponent, ObservableObject {
    
    // MARK: - Identity
    
    /// Unique identifier for this component
    public let id = UUID()
    
    /// Human-readable name (override in subclasses)
    open var name: String = "Unnamed Component"
    
    /// The hierarchy level of this component (override in subclasses)
    open var hierarchyLevel: HierarchyLevel = .component
    
    /// Component version
    open var version: ComponentVersion = ComponentVersion(1, 0, 0)
    
    /// SF Symbol icon name (override in subclasses)
    open var icon: String = "cube"
    
    /// Component description for documentation
    open var description: String = ""
    
    // MARK: - Structure
    
    /// Parent component reference
    public weak var parent: (any UniversalComponent)?
    
    /// Child components
    @Published public var children: [any UniversalComponent] = []
    
    /// Component dependencies by ID
    open var dependencies: [UUID] = []
    
    /// Capabilities this component provides
    open var capabilities: [ComponentCapability] = []
    
    // MARK: - Interface
    
    /// The SwiftUI view for this component
    public var view: AnyView {
        createView()
    }
    
    /// Component configuration
    @Published public var configuration = ComponentConfiguration()
    
    /// Runtime state management
    @Published public var state = ComponentState()
    
    // MARK: - Metrics & Health
    
    /// Component performance metrics
    @Published public var metrics = ComponentMetrics()
    
    /// Component health status
    @Published public var health = ComponentHealth()
    
    // MARK: - Private Properties
    
    /// Message handler for async operations
    private var messageHandler: AnyCancellable?
    
    /// Lifecycle state tracking
    private var isInitialized = false
    
    // MARK: - Initialization
    
    /// Initialize the base component
    public init() {
        setupObservation()
    }
    
    // MARK: - Lifecycle Implementation
    
    /// Initialize the component and its resources
    public func initialize() async throws {
        guard !isInitialized else { return }
        
        updateStatus(.initializing)
        
        do {
            // Initialize dependencies first
            try await initializeDependencies()
            
            // Perform custom initialization
            try await performInitialization()
            
            // Initialize all children
            for child in children {
                try await child.initialize()
            }
            
            isInitialized = true
            updateStatus(.ready)
            
        } catch {
            updateStatus(.error)
            throw ComponentError.initializationFailed(error.localizedDescription)
        }
    }
    
    /// Execute the component's primary function
    public func execute() async throws -> ComponentResult {
        guard isInitialized else {
            throw ComponentError.notInitialized
        }
        
        updateStatus(.executing)
        let startTime = Date()
        
        do {
            // Update metrics
            metrics.executionCount += 1
            metrics.lastExecution = startTime
            
            // Perform the actual execution
            let result = try await performExecution()
            
            // Update metrics with results
            let duration = Date().timeIntervalSince(startTime)
            metrics.totalDuration += duration
            
            updateStatus(.ready)
            return result
            
        } catch {
            metrics.executionCount -= 1 // Don't count failed executions
            state.errorCount += 1
            updateStatus(.error)
            throw error
        }
    }
    
    /// Suspend component operation
    public func suspend() async throws {
        guard state.status == .ready || state.status == .executing else {
            throw ComponentError.invalidState("Cannot suspend from \(state.status)")
        }
        
        updateStatus(.suspended)
        
        // Suspend all children
        for child in children {
            try await child.suspend()
        }
        
        try await performSuspension()
    }
    
    /// Resume component operation
    public func resume() async throws {
        guard state.status == .suspended else {
            throw ComponentError.invalidState("Cannot resume from \(state.status)")
        }
        
        try await performResumption()
        
        // Resume all children
        for child in children {
            try await child.resume()
        }
        
        updateStatus(.ready)
    }
    
    /// Clean up resources before removal
    public func cleanup() async throws {
        updateStatus(.cleaning)
        
        // Cleanup children first
        for child in children {
            try await child.cleanup()
        }
        
        // Perform custom cleanup
        try await performCleanup()
        
        // Clear references
        children.removeAll()
        parent = nil
        
        updateStatus(.uninitialized)
        isInitialized = false
    }
    
    /// Check if component can be safely unloaded
    public func canUnload() -> Bool {
        // Check if any children cannot unload
        if children.contains(where: { !$0.canUnload() }) {
            return false
        }
        
        // Check custom conditions
        return performCanUnload()
    }
    
    // MARK: - Communication Implementation
    
    /// Receive a message from another component
    public func receiveMessage(_ message: ComponentMessage) async throws {
        // Handle system messages
        switch message.type {
        case .command:
            try await handleCommand(message)
        case .query:
            try await handleQuery(message)
        case .event:
            try await handleEvent(message)
        default:
            try await handleCustomMessage(message)
        }
    }
    
    /// Send a message to a specific component
    public func sendMessage(_ message: ComponentMessage, to recipient: UUID) async throws {
        // Find recipient in hierarchy
        if let target = findComponent(by: recipient) {
            try await target.receiveMessage(message)
        } else {
            throw ComponentError.recipientNotFound(recipient)
        }
    }
    
    /// Broadcast a message to all children
    public func broadcast(_ message: ComponentMessage) async throws {
        for child in children {
            try await child.receiveMessage(message)
        }
    }
    
    // MARK: - CICD Implementation
    
    /// Run component tests
    public func test() async throws -> TestResult {
        let startTime = Date()
        var passed = 0
        var failed = 0
        var failures: [TestResult.TestFailure] = []
        
        // Run custom tests
        let customResult = try await performTests()
        passed += customResult.passed
        failed += customResult.failed
        failures.append(contentsOf: customResult.failures)
        
        // Test all children
        for child in children {
            let childResult = try await child.test()
            passed += childResult.passed
            failed += childResult.failed
            failures.append(contentsOf: childResult.failures)
        }
        
        let duration = Date().timeIntervalSince(startTime)
        let coverage = calculateTestCoverage()
        
        return TestResult(
            passed: passed,
            failed: failed,
            skipped: 0,
            duration: duration,
            coverage: coverage,
            failures: failures
        )
    }
    
    /// Build the component
    public func build() async throws -> BuildArtifact {
        // Perform custom build
        let artifact = try await performBuild()
        
        // Build all children
        for child in children {
            _ = try await child.build()
        }
        
        return artifact
    }
    
    /// Deploy the component
    public func deploy(to environment: DeploymentEnvironment) async throws {
        // Validate before deployment
        let validation = try await validate()
        guard validation.isValid else {
            throw ComponentError.validationFailed(validation.errors)
        }
        
        // Perform deployment
        try await performDeployment(to: environment)
        
        // Deploy all children
        for child in children {
            try await child.deploy(to: environment)
        }
    }
    
    /// Validate component integrity
    public func validate() async throws -> ValidationResult {
        var errors: [ValidationResult.ValidationError] = []
        var warnings: [ValidationResult.ValidationWarning] = []
        
        // Perform custom validation
        let customResult = try await performValidation()
        errors.append(contentsOf: customResult.errors)
        warnings.append(contentsOf: customResult.warnings)
        
        // Validate all children
        for child in children {
            let childResult = try await child.validate()
            errors.append(contentsOf: childResult.errors)
            warnings.append(contentsOf: childResult.warnings)
        }
        
        return ValidationResult(
            isValid: errors.isEmpty,
            errors: errors,
            warnings: warnings
        )
    }
    
    // MARK: - Protected Methods (Override in Subclasses)
    
    /// Create the component's view (override in subclasses)
    open func createView() -> AnyView {
        AnyView(
            VStack {
                Label(name, systemImage: icon)
                    .font(.headline)
                Text(hierarchyLevel.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(hierarchyLevel.color.opacity(0.1))
            .cornerRadius(8)
        )
    }
    
    /// Perform custom initialization (override in subclasses)
    open func performInitialization() async throws {
        // Default: no additional initialization
    }
    
    /// Perform the component's execution (override in subclasses)
    open func performExecution() async throws -> ComponentResult {
        // Default: successful no-op
        return ComponentResult(success: true, duration: 0)
    }
    
    /// Perform custom suspension logic (override in subclasses)
    open func performSuspension() async throws {
        // Default: no additional suspension logic
    }
    
    /// Perform custom resumption logic (override in subclasses)
    open func performResumption() async throws {
        // Default: no additional resumption logic
    }
    
    /// Perform custom cleanup (override in subclasses)
    open func performCleanup() async throws {
        // Default: no additional cleanup
    }
    
    /// Check custom unload conditions (override in subclasses)
    open func performCanUnload() -> Bool {
        // Default: can always unload if no children object
        return true
    }
    
    /// Handle custom messages (override in subclasses)
    open func handleCustomMessage(_ message: ComponentMessage) async throws {
        // Default: ignore unknown messages
    }
    
    /// Perform component tests (override in subclasses)
    open func performTests() async throws -> TestResult {
        // Default: no tests
        return TestResult(
            passed: 0,
            failed: 0,
            skipped: 0,
            duration: 0,
            coverage: 0,
            failures: []
        )
    }
    
    /// Perform component build (override in subclasses)
    open func performBuild() async throws -> BuildArtifact {
        // Default: create a simple artifact
        return BuildArtifact(
            id: UUID(),
            version: version,
            path: "/tmp/\(id.uuidString)",
            size: 0,
            checksum: "",
            metadata: [:],
            timestamp: Date()
        )
    }
    
    /// Perform deployment (override in subclasses)
    open func performDeployment(to environment: DeploymentEnvironment) async throws {
        // Default: no-op deployment
    }
    
    /// Perform validation (override in subclasses)
    open func performValidation() async throws -> ValidationResult {
        // Default: always valid
        return ValidationResult(isValid: true, errors: [], warnings: [])
    }
    
    // MARK: - Private Methods
    
    /// Update component status
    private func updateStatus(_ newStatus: ComponentStatus) {
        state.status = newStatus
        state.lastActivity = Date()
    }
    
    /// Setup observation for state changes
    private func setupObservation() {
        // Could add Combine publishers here for state observation
    }
    
    /// Initialize dependencies
    private func initializeDependencies() async throws {
        // In a real implementation, would resolve and initialize dependencies
    }
    
    /// Find a component by ID in the hierarchy
    private func findComponent(by id: UUID) -> (any UniversalComponent)? {
        if self.id == id { return self }
        
        for child in children {
            if let found = (child as? BaseComponent)?.findComponent(by: id) {
                return found
            }
        }
        
        return nil
    }
    
    /// Handle command messages
    private func handleCommand(_ message: ComponentMessage) async throws {
        // Default command handling
        if let command = message.payload["command"]?.value as? String {
            switch command {
            case "refresh":
                _ = try await execute()
            case "validate":
                _ = try await validate()
            default:
                try await handleCustomMessage(message)
            }
        }
    }
    
    /// Handle query messages
    private func handleQuery(_ message: ComponentMessage) async throws {
        // Default query handling
        if let query = message.payload["query"]?.value as? String {
            switch query {
            case "status":
                let response = ComponentMessage(
                    source: id,
                    destination: message.source,
                    type: .response,
                    payload: ["status": AnyCodable(state.status.rawValue)]
                )
                try await sendMessage(response, to: message.source)
            default:
                try await handleCustomMessage(message)
            }
        }
    }
    
    /// Handle event messages
    private func handleEvent(_ message: ComponentMessage) async throws {
        // Default: forward to custom handler
        try await handleCustomMessage(message)
    }
    
    /// Calculate test coverage
    private func calculateTestCoverage() -> Double {
        // In a real implementation, would calculate actual coverage
        return 0.0
    }
}

// MARK: - Component Errors

/// Errors that can occur in component operations
public enum ComponentError: LocalizedError {
    case notInitialized
    case initializationFailed(String)
    case invalidState(String)
    case recipientNotFound(UUID)
    case validationFailed([ValidationResult.ValidationError])
    case dependencyMissing(UUID)
    case circularDependency([UUID])
    
    public var errorDescription: String? {
        switch self {
        case .notInitialized:
            return "Component has not been initialized"
        case .initializationFailed(let reason):
            return "Initialization failed: \(reason)"
        case .invalidState(let message):
            return "Invalid state: \(message)"
        case .recipientNotFound(let id):
            return "Recipient not found: \(id)"
        case .validationFailed(let errors):
            return "Validation failed with \(errors.count) errors"
        case .dependencyMissing(let id):
            return "Missing dependency: \(id)"
        case .circularDependency(let chain):
            return "Circular dependency detected: \(chain.map { $0.uuidString }.joined(separator: " -> "))"
        }
    }
}