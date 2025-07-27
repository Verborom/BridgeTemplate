# ``UniversalTemplate``

The revolutionary template system that powers every component in Bridge Template, enabling infinite recursive modularity at any hierarchy level.

## Overview

UniversalTemplate is a groundbreaking framework that unifies all component types in the Bridge Template ecosystem. Whether you're building a Module, Epic, Feature, Task, or any other component type, they all use this single, powerful template system.

![UniversalTemplate Overview](UniversalTemplate-Overview)

### Key Features

- **🌍 Universal Interface**: One protocol for all hierarchy levels
- **♾️ Infinite Nesting**: Components can contain components infinitely
- **🔄 Hot-Swappable**: Runtime replacement without restart
- **🤖 Full CICD**: Automated testing and deployment at every level
- **📦 Self-Contained**: Each component is a complete package
- **🧬 Dynamic Creation**: Runtime instantiation from templates

## Topics

### Essentials

- <doc:GettingStarted>
- <doc:CreatingYourFirstComponent>
- ``UniversalComponent``
- ``BaseComponent``

### Component Creation

- ``ComponentFactory``
- <doc:TemplateSystem>
- <doc:DynamicCreation>
- <doc:BatchCreation>

### Hierarchy Management

- ``HierarchyManager``
- <doc:ParentChildRelationships>
- <doc:DependencyResolution>
- <doc:TreeTraversal>

### Component Lifecycle

- <doc:Initialization>
- <doc:Execution>
- <doc:Suspension>
- <doc:Cleanup>

### Communication

- <doc:MessagePassing>
- <doc:EventPropagation>
- <doc:CrossComponentCommunication>

### CICD Integration

- <doc:AutomatedTesting>
- <doc:ContinuousIntegration>
- <doc:DeploymentStrategies>
- <doc:VersionManagement>

### Advanced Topics

- <doc:CustomComponents>
- <doc:ComponentBuilders>
- <doc:HierarchyRules>
- <doc:PerformanceOptimization>

## Architecture

The UniversalTemplate architecture consists of several key components:

```
┌─────────────────────────────────────────────┐
│            UniversalComponent               │
│         (Protocol Definition)               │
└─────────────────────┬───────────────────────┘
                      │
        ┌─────────────┴─────────────┐
        │                           │
┌───────▼────────┐         ┌───────▼────────┐
│  BaseComponent │         │ ComponentFactory│
│(Default Impl)  │         │ (Dynamic Create)│
└────────────────┘         └─────────────────┘
        │                           │
        └─────────────┬─────────────┘
                      │
              ┌───────▼────────┐
              │HierarchyManager│
              │ (Relationships) │
              └────────────────┘
```

## Example Usage

### Creating a Simple Component

```swift
class SearchFeature: BaseComponent {
    override init() {
        super.init()
        self.name = "Advanced Search"
        self.hierarchyLevel = .feature
        self.version = ComponentVersion(1, 0, 0)
        self.icon = "magnifyingglass"
    }
    
    override func createView() -> AnyView {
        AnyView(SearchView())
    }
    
    override func performExecution() async throws -> ComponentResult {
        // Perform search logic
        let results = try await performSearch()
        return ComponentResult(
            success: true,
            output: AnyCodable(results),
            duration: 0.5
        )
    }
}
```

### Using the Factory

```swift
// Create from configuration
let config = ComponentCreationConfig(
    name: "User Dashboard",
    hierarchyLevel: .module,
    version: ComponentVersion(2, 1, 0)
)

let dashboard = try await ComponentFactory.shared.create(from: config)

// Add child components
let statsWidget = try await factory.create(from: statsConfig)
try await hierarchyManager.addChild(statsWidget, to: dashboard)
```

### Managing Hierarchy

```swift
let manager = HierarchyManager()

// Build a feature hierarchy
let epic = try await factory.create(from: epicConfig)
let story1 = try await factory.create(from: story1Config)
let story2 = try await factory.create(from: story2Config)

try await manager.addChild(story1, to: epic)
try await manager.addChild(story2, to: epic)

// Add features to stories
for feature in features {
    try await manager.addChild(feature, to: story1)
}
```

## Design Philosophy

UniversalTemplate embodies several key design principles:

1. **Uniformity**: Every component, regardless of size or complexity, uses the same interface
2. **Composability**: Components combine to create larger components
3. **Isolation**: Each component is self-contained with its own lifecycle
4. **Flexibility**: The same template adapts to any use case
5. **Automation**: CICD is built-in, not bolted on

## Performance Considerations

- Components are lazy-loaded when possible
- View rendering is optimized for SwiftUI
- Message passing uses efficient routing
- Dependency resolution is cached

## Migration Guide

For existing Bridge Template projects:

1. Identify current module structure
2. Map to UniversalComponent hierarchy levels
3. Gradually migrate using the adapter pattern
4. Leverage ComponentFactory for new components

## See Also

- [Bridge Template Documentation](https://github.com/Verborom/BridgeTemplate)
- <doc:APIReference>
- <doc:Tutorials>