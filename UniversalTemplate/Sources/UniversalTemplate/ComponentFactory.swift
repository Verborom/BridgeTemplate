import SwiftUI
import Foundation

/// # ComponentFactory
///
/// The factory class responsible for dynamically creating components at runtime.
/// This enables the Bridge Template system to instantiate any component type
/// from templates, configurations, or even network responses.
///
/// ## Overview
///
/// ComponentFactory is the engine of dynamic component creation. It can:
/// - **Create from Templates**: Instantiate components from template definitions
/// - **Create from Configuration**: Build components from JSON/YAML configs
/// - **Create Dynamically**: Generate components based on runtime conditions
/// - **Register Custom Types**: Add new component types without recompiling
/// - **Validate Creation**: Ensure components meet requirements before creation
///
/// ## Usage
///
/// ```swift
/// let factory = ComponentFactory.shared
/// 
/// // Register a custom component type
/// factory.register(MyCustomFeature.self, for: .feature)
/// 
/// // Create from configuration
/// let config = ComponentConfiguration(name: "UserProfile", type: .feature)
/// let component = try await factory.create(from: config)
/// 
/// // Create from template
/// let template = try await factory.loadTemplate("advanced-search")
/// let searchFeature = try await factory.instantiate(template)
/// ```
@MainActor
public final class ComponentFactory {
    
    /// Shared factory instance
    public static let shared = ComponentFactory()
    
    /// Registry of component types
    private var registry: [HierarchyLevel: () -> any UniversalComponent] = [:]
    
    /// Template cache
    private var templateCache: [String: ComponentTemplate] = [:]
    
    /// Component builders for custom creation logic
    private var builders: [String: ComponentBuilder] = [:]
    
    /// Private initializer for singleton
    private init() {
        registerDefaultComponents()
    }
    
    // MARK: - Registration
    
    /// Register a component type for a hierarchy level
    ///
    /// - Parameters:
    ///   - componentType: The component class to register
    ///   - level: The hierarchy level this component represents
    public func register<T: UniversalComponent>(_ componentType: T.Type, for level: HierarchyLevel) where T: BaseComponent {
        registry[level] = { T() }
    }
    
    /// Register a custom builder for complex component creation
    ///
    /// - Parameters:
    ///   - builder: The builder instance
    ///   - identifier: Unique identifier for this builder
    public func registerBuilder(_ builder: ComponentBuilder, identifier: String) {
        builders[identifier] = builder
    }
    
    // MARK: - Component Creation
    
    /// Create a component from a configuration
    ///
    /// - Parameter config: Component configuration
    /// - Returns: Newly created component
    /// - Throws: FactoryError if creation fails
    public func create(from config: ComponentCreationConfig) async throws -> any UniversalComponent {
        // Validate configuration
        try validateConfiguration(config)
        
        // Get appropriate component type
        guard let componentCreator = registry[config.hierarchyLevel] else {
            // Fallback to base component
            return try await createBaseComponent(from: config)
        }
        
        // Use custom builder if specified
        if let builderID = config.builderId,
           let builder = builders[builderID] {
            return try await builder.build(from: config)
        }
        
        // Create component instance
        let component = componentCreator()
        
        // Configure component
        try await configureComponent(component, with: config)
        
        return component
    }
    
    /// Create a component from a template
    ///
    /// - Parameter template: Component template
    /// - Returns: Newly created component
    public func instantiate(_ template: ComponentTemplate) async throws -> any UniversalComponent {
        // Convert template to configuration
        let config = try template.toConfiguration()
        
        // Create component
        let component = try await create(from: config)
        
        // Apply template-specific settings
        try await applyTemplate(template, to: component)
        
        return component
    }
    
    /// Create multiple components from a batch configuration
    ///
    /// - Parameter batchConfig: Batch creation configuration
    /// - Returns: Array of created components
    public func createBatch(from batchConfig: BatchCreationConfig) async throws -> [any UniversalComponent] {
        var components: [any UniversalComponent] = []
        
        for config in batchConfig.components {
            let component = try await create(from: config)
            components.append(component)
        }
        
        // Link components if specified
        if batchConfig.autoLink {
            try await linkComponents(components, using: batchConfig.linkingStrategy)
        }
        
        return components
    }
    
    // MARK: - Template Management
    
    /// Load a component template
    ///
    /// - Parameter identifier: Template identifier
    /// - Returns: Component template
    public func loadTemplate(_ identifier: String) async throws -> ComponentTemplate {
        // Check cache first
        if let cached = templateCache[identifier] {
            return cached
        }
        
        // Load from file system
        let template = try await loadTemplateFromDisk(identifier)
        
        // Cache for future use
        templateCache[identifier] = template
        
        return template
    }
    
    /// Save a component as a template
    ///
    /// - Parameters:
    ///   - component: Component to save as template
    ///   - identifier: Template identifier
    public func saveAsTemplate(_ component: any UniversalComponent, identifier: String) async throws {
        let template = try await createTemplate(from: component)
        
        // Save to disk
        try await saveTemplateToDisk(template, identifier: identifier)
        
        // Update cache
        templateCache[identifier] = template
    }
    
    // MARK: - Hierarchy Creation
    
    /// Create a complete component hierarchy
    ///
    /// - Parameter definition: Hierarchy definition
    /// - Returns: Root component with full hierarchy
    public func createHierarchy(from definition: HierarchyDefinition) async throws -> any UniversalComponent {
        // Create root component
        let root = try await create(from: definition.root)
        
        // Recursively create children
        for childDef in definition.children {
            let child = try await createHierarchyNode(from: childDef)
            root.children.append(child)
            child.parent = root
        }
        
        return root
    }
    
    // MARK: - Dynamic Creation
    
    /// Create a component dynamically based on runtime conditions
    ///
    /// - Parameters:
    ///   - requirements: Component requirements
    ///   - context: Runtime context
    /// - Returns: Dynamically created component
    public func createDynamic(
        matching requirements: ComponentRequirements,
        context: RuntimeContext
    ) async throws -> any UniversalComponent {
        // Analyze requirements and context
        let analysis = try await analyzeRequirements(requirements, context: context)
        
        // Determine best component type
        let _ = analysis.recommendedLevel
        let config = analysis.suggestedConfiguration
        
        // Create component
        return try await create(from: config)
    }
    
    // MARK: - Private Methods
    
    /// Register default component implementations
    private func registerDefaultComponents() {
        // Register base implementations for each level
        // In production, these would be actual implementations
        for level in HierarchyLevel.allCases {
            registry[level] = { BaseComponent() }
        }
    }
    
    /// Create a base component with configuration
    private func createBaseComponent(from config: ComponentCreationConfig) async throws -> any UniversalComponent {
        let component = BaseComponent()
        component.name = config.name
        component.hierarchyLevel = config.hierarchyLevel
        component.version = config.version
        component.icon = config.icon ?? "cube"
        component.description = config.description ?? ""
        component.capabilities = config.capabilities
        
        return component
    }
    
    /// Configure a component with creation config
    private func configureComponent(_ component: any UniversalComponent, with config: ComponentCreationConfig) async throws {
        // Set basic properties
        if let baseComponent = component as? BaseComponent {
            baseComponent.name = config.name
            baseComponent.hierarchyLevel = config.hierarchyLevel
            baseComponent.version = config.version
            baseComponent.icon = config.icon ?? "cube"
            baseComponent.description = config.description ?? ""
            baseComponent.capabilities = config.capabilities
        }
        
        // Apply configuration
        component.configuration = config.configuration
        
        // Add initial children
        for childConfig in config.children {
            let child = try await create(from: childConfig)
            component.children.append(child)
            child.parent = component
        }
    }
    
    /// Validate component configuration
    private func validateConfiguration(_ config: ComponentCreationConfig) throws {
        // Validate required fields
        guard !config.name.isEmpty else {
            throw FactoryError.invalidConfiguration("Component name cannot be empty")
        }
        
        // Validate version
        guard config.version.major >= 0 else {
            throw FactoryError.invalidConfiguration("Invalid version number")
        }
        
        // Validate hierarchy constraints
        if let parent = config.parentLevel {
            guard config.hierarchyLevel.weight < parent.weight else {
                throw FactoryError.hierarchyViolation(
                    "Child level \(config.hierarchyLevel) cannot be higher than parent \(parent)"
                )
            }
        }
    }
    
    /// Apply template settings to component
    private func applyTemplate(_ template: ComponentTemplate, to component: any UniversalComponent) async throws {
        // Apply template-specific configurations
        if let templateConfig = template.additionalConfiguration {
            for (key, value) in templateConfig {
                component.configuration.settings[key] = value
            }
        }
        
        // Apply template features
        component.configuration.features = template.features
        
        // Apply template permissions
        component.configuration.permissions = template.permissions
    }
    
    /// Create hierarchy node recursively
    private func createHierarchyNode(from definition: HierarchyNodeDefinition) async throws -> any UniversalComponent {
        let component = try await create(from: definition.config)
        
        for childDef in definition.children {
            let child = try await createHierarchyNode(from: childDef)
            component.children.append(child)
            child.parent = component
        }
        
        return component
    }
    
    /// Link components based on strategy
    private func linkComponents(_ components: [any UniversalComponent], using strategy: LinkingStrategy) async throws {
        switch strategy {
        case .sequential:
            // Link components in sequence
            for i in 1..<components.count {
                components[i].parent = components[i-1]
                components[i-1].children.append(components[i])
            }
            
        case .hierarchical(_):
            // Link based on hierarchical structure
            // Implementation depends on structure definition
            break
            
        case .mesh:
            // Create mesh connections (all interconnected)
            // Implementation for mesh topology
            break
            
        case .custom(let linker):
            // Use custom linking logic
            try await linker.link(components)
        }
    }
    
    /// Load template from disk
    private func loadTemplateFromDisk(_ identifier: String) async throws -> ComponentTemplate {
        let templatePath = templateDirectory.appendingPathComponent("\(identifier).json")
        let data = try Data(contentsOf: templatePath)
        return try JSONDecoder().decode(ComponentTemplate.self, from: data)
    }
    
    /// Save template to disk
    private func saveTemplateToDisk(_ template: ComponentTemplate, identifier: String) async throws {
        let templatePath = templateDirectory.appendingPathComponent("\(identifier).json")
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(template)
        try data.write(to: templatePath)
    }
    
    /// Create template from component
    private func createTemplate(from component: any UniversalComponent) async throws -> ComponentTemplate {
        return ComponentTemplate(
            id: UUID(),
            name: component.name,
            hierarchyLevel: component.hierarchyLevel,
            version: component.version,
            icon: component.icon,
            description: component.description,
            capabilities: component.capabilities,
            configuration: component.configuration,
            features: component.configuration.features,
            permissions: component.configuration.permissions,
            additionalConfiguration: component.configuration.settings
        )
    }
    
    /// Analyze requirements for dynamic creation
    private func analyzeRequirements(
        _ requirements: ComponentRequirements,
        context: RuntimeContext
    ) async throws -> RequirementAnalysis {
        // Analyze requirements and determine optimal component type
        // This is a simplified implementation
        
        let recommendedLevel: HierarchyLevel
        if requirements.complexity > 0.8 {
            recommendedLevel = .module
        } else if requirements.complexity > 0.6 {
            recommendedLevel = .feature
        } else if requirements.complexity > 0.4 {
            recommendedLevel = .component
        } else {
            recommendedLevel = .task
        }
        
        let config = ComponentCreationConfig(
            name: requirements.suggestedName ?? "Dynamic Component",
            hierarchyLevel: recommendedLevel,
            version: ComponentVersion(1, 0, 0),
            icon: requirements.suggestedIcon,
            description: requirements.description,
            capabilities: requirements.requiredCapabilities,
            configuration: ComponentConfiguration(),
            children: []
        )
        
        return RequirementAnalysis(
            recommendedLevel: recommendedLevel,
            suggestedConfiguration: config,
            confidence: 0.85
        )
    }
    
    /// Template directory URL
    private var templateDirectory: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent("UniversalTemplates")
    }
}

// MARK: - Supporting Types

/// Component creation configuration
public struct ComponentCreationConfig {
    public let name: String
    public let hierarchyLevel: HierarchyLevel
    public let version: ComponentVersion
    public let icon: String?
    public let description: String?
    public let capabilities: [ComponentCapability]
    public let configuration: ComponentConfiguration
    public let children: [ComponentCreationConfig]
    public let builderId: String?
    public let parentLevel: HierarchyLevel?
    
    public init(
        name: String,
        hierarchyLevel: HierarchyLevel,
        version: ComponentVersion,
        icon: String? = nil,
        description: String? = nil,
        capabilities: [ComponentCapability] = [],
        configuration: ComponentConfiguration = ComponentConfiguration(),
        children: [ComponentCreationConfig] = [],
        builderId: String? = nil,
        parentLevel: HierarchyLevel? = nil
    ) {
        self.name = name
        self.hierarchyLevel = hierarchyLevel
        self.version = version
        self.icon = icon
        self.description = description
        self.capabilities = capabilities
        self.configuration = configuration
        self.children = children
        self.builderId = builderId
        self.parentLevel = parentLevel
    }
}

/// Component template
public struct ComponentTemplate: Codable {
    public let id: UUID
    public let name: String
    public let hierarchyLevel: HierarchyLevel
    public let version: ComponentVersion
    public let icon: String
    public let description: String
    public let capabilities: [ComponentCapability]
    public let configuration: ComponentConfiguration
    public let features: Set<String>
    public let permissions: Set<String>
    public let additionalConfiguration: [String: AnyCodable]?
    
    /// Convert template to creation configuration
    public func toConfiguration() throws -> ComponentCreationConfig {
        return ComponentCreationConfig(
            name: name,
            hierarchyLevel: hierarchyLevel,
            version: version,
            icon: icon,
            description: description,
            capabilities: capabilities,
            configuration: configuration
        )
    }
}

/// Batch creation configuration
public struct BatchCreationConfig {
    public let components: [ComponentCreationConfig]
    public let autoLink: Bool
    public let linkingStrategy: LinkingStrategy
    
    public init(
        components: [ComponentCreationConfig],
        autoLink: Bool = false,
        linkingStrategy: LinkingStrategy = .sequential
    ) {
        self.components = components
        self.autoLink = autoLink
        self.linkingStrategy = linkingStrategy
    }
}

/// Component linking strategy
public enum LinkingStrategy {
    case sequential
    case hierarchical(HierarchicalStructure)
    case mesh
    case custom(ComponentLinker)
}

/// Hierarchical structure definition
public struct HierarchicalStructure {
    public let levels: [HierarchyLevel: [Int]]
}

/// Protocol for custom component builders
public protocol ComponentBuilder {
    func build(from config: ComponentCreationConfig) async throws -> any UniversalComponent
}

/// Protocol for custom component linkers
public protocol ComponentLinker {
    func link(_ components: [any UniversalComponent]) async throws
}

/// Hierarchy definition for complex structures
public struct HierarchyDefinition {
    public let root: ComponentCreationConfig
    public let children: [HierarchyNodeDefinition]
}

/// Hierarchy node definition
public struct HierarchyNodeDefinition {
    public let config: ComponentCreationConfig
    public let children: [HierarchyNodeDefinition]
}

/// Component requirements for dynamic creation
public struct ComponentRequirements {
    public let complexity: Double // 0.0 to 1.0
    public let requiredCapabilities: [ComponentCapability]
    public let suggestedName: String?
    public let suggestedIcon: String?
    public let description: String?
}

/// Runtime context for dynamic creation
public struct RuntimeContext {
    public let environment: [String: String]
    public let availableResources: [String: Any]
    public let constraints: [String: Any]
}

/// Requirement analysis result
public struct RequirementAnalysis {
    public let recommendedLevel: HierarchyLevel
    public let suggestedConfiguration: ComponentCreationConfig
    public let confidence: Double
}

/// Factory errors
public enum FactoryError: LocalizedError {
    case invalidConfiguration(String)
    case hierarchyViolation(String)
    case templateNotFound(String)
    case builderNotFound(String)
    case creationFailed(String)
    
    public var errorDescription: String? {
        switch self {
        case .invalidConfiguration(let message):
            return "Invalid configuration: \(message)"
        case .hierarchyViolation(let message):
            return "Hierarchy violation: \(message)"
        case .templateNotFound(let id):
            return "Template not found: \(id)"
        case .builderNotFound(let id):
            return "Builder not found: \(id)"
        case .creationFailed(let reason):
            return "Component creation failed: \(reason)"
        }
    }
}