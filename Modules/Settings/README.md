# Settings 🌍

The revolutionary template system that powers every component in Bridge Template, from the highest-level Module down to the smallest Task. One template to rule them all.

## 🚀 Overview

Settings is a groundbreaking framework that unifies ALL component types in the Bridge Template ecosystem. It provides complete CICD automation, Swift package structure, versioning, testing, and documentation - identical for every component at every level.

### Key Innovation

Instead of having different templates for Modules, Features, Tasks, etc., Settings provides a single, powerful template that adapts to ANY hierarchy level. This enables:

- **♾️ Infinite Nesting**: Any component can contain any other component
- **🔄 Complete Reusability**: One template serves all purposes
- **🤖 Full Automation**: CICD at every level, not just the top
- **📦 Self-Contained**: Each component is a complete, deployable unit
- **🧬 Runtime Creation**: Dynamically instantiate components on demand

## 📋 Features

### Universal Component Protocol
- Single protocol for ALL hierarchy levels
- Complete lifecycle management
- Built-in communication system
- Automatic state management
- Performance metrics tracking

### Hierarchy Management
- Parent-child relationships
- Dependency resolution
- Circular dependency prevention
- Tree traversal operations
- Event propagation (bubble up/broadcast down)

### CICD Integration
- GitHub Actions workflow for any component
- Automated testing at every level
- Continuous deployment support
- Version management and migration
- Platform-specific builds (macOS, iOS, watchOS, tvOS, visionOS)

### Dynamic Creation
- Runtime component instantiation
- Template-based creation
- Configuration-driven components
- Batch creation support
- Custom builders and factories

## 🏗️ Architecture

```
Settings/
├── Sources/
│   └── Settings/
│       ├── UniversalComponent.swift      # Core protocol
│       ├── BaseComponent.swift           # Default implementation
│       ├── ComponentFactory.swift        # Dynamic creation
│       ├── HierarchyManager.swift        # Relationship management
│       ├── VersionManager.swift          # Version control
│       └── Examples/
│           └── DashboardModule.swift     # Complete example
├── Tests/
│   └── SettingsTests/
├── CICD/
│   └── Workflows/
│       └── universal-component.yml       # GitHub Actions
├── Documentation/
│   └── Settings.docc/          # Swift DocC
└── Package.swift                        # Swift Package
```

## 🚦 Getting Started

### Installation

Add Settings to your Swift package dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/Verborom/BridgeTemplate/Settings", from: "1.0.0")
]
```

### Creating Your First Component

1. **Inherit from BaseComponent**:

```swift
@MainActor
class MyFeature: BaseComponent {
    override init() {
        super.init()
        self.name = "Amazing Feature"
        self.hierarchyLevel = .feature
        self.version = ComponentVersion(1, 0, 0)
        self.icon = "star.fill"
    }
    
    override func createView() -> AnyView {
        AnyView(MyFeatureView())
    }
    
    override func performExecution() async throws -> ComponentResult {
        // Your feature logic here
        return ComponentResult(success: true, duration: 0.1)
    }
}
```

2. **Use the ComponentFactory**:

```swift
let factory = ComponentFactory.shared

// Create from configuration
let config = ComponentCreationConfig(
    name: "User Dashboard",
    hierarchyLevel: .module,
    version: ComponentVersion(1, 0, 0)
)

let dashboard = try await factory.create(from: config)
```

3. **Manage Hierarchy**:

```swift
let manager = HierarchyManager()

// Add children
try await manager.addChild(myFeature, to: dashboard)

// Move components
try await manager.moveComponent(myFeature, to: newParent)
```

## 🎯 Hierarchy Levels

Settings supports these hierarchy levels (and you can add more):

- **App**: Top-level application
- **Module**: Major functional areas
- **Submodule**: Module subdivisions
- **Epic**: Large feature sets
- **Story**: User stories
- **Feature**: Individual features
- **Component**: Reusable components
- **Widget**: UI widgets
- **Task**: Specific tasks
- **Subtask**: Task subdivisions
- **Microservice**: Service components
- **Utility**: Helper components

## 🔧 Advanced Usage

### Custom Components

Create specialized components by overriding BaseComponent methods:

```swift
override func performInitialization() async throws {
    // Custom initialization
}

override func handleCustomMessage(_ message: ComponentMessage) async throws {
    // Handle messages
}

override func performTests() async throws -> TestResult {
    // Custom tests
}
```

### Dynamic Creation

Create components at runtime based on requirements:

```swift
let requirements = ComponentRequirements(
    complexity: 0.7,
    requiredCapabilities: [capability1, capability2],
    suggestedName: "Dynamic Feature"
)

let component = try await factory.createDynamic(
    matching: requirements,
    context: runtimeContext
)
```

### Version Management

Handle component versioning and migration:

```swift
let versionManager = VersionManager.shared

// Check compatibility
if versionManager.areCompatible(current: v1, target: v2) {
    try await versionManager.migrate(component, from: v1, to: v2)
}

// Rollback if needed
try await versionManager.rollback(component, to: previousVersion)
```

## 🧪 Testing

Every component has built-in testing capabilities:

```swift
// Run component tests
let result = try await component.test()
print("Tests passed: \(result.passed), failed: \(result.failed)")

// Validate component
let validation = try await component.validate()
if !validation.isValid {
    print("Validation errors: \(validation.errors)")
}
```

## 📚 Documentation

Settings uses Swift DocC for comprehensive documentation:

```bash
# Generate documentation
swift package generate-documentation

# Preview documentation
swift package preview-documentation
```

## 🚀 CICD

The universal GitHub Actions workflow handles:

1. **Analysis**: Component structure analysis
2. **Quality**: Linting and formatting
3. **Build**: Multi-platform builds
4. **Test**: Automated testing
5. **Documentation**: DocC generation
6. **Package**: Create distributable
7. **Deploy**: Environment deployment
8. **Integration**: Integration tests
9. **Release**: Automated releases

Trigger manually:

```bash
gh workflow run universal-component.yml \
  -f component_path=./MyComponent \
  -f hierarchy_level=feature \
  -f deploy_environment=staging
```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch
3. Make your changes
4. Add tests
5. Update documentation
6. Submit a pull request

## 📄 License

Settings is part of the Bridge Template project and follows the same license.

## 🔗 Links

- [Bridge Template](https://github.com/Verborom/BridgeTemplate)
- [Documentation](https://verborom.github.io/BridgeTemplate/Settings)
- [API Reference](https://verborom.github.io/BridgeTemplate/Settings/documentation)

---

**Remember**: With Settings, every component is a complete, self-contained unit with its own lifecycle, testing, documentation, and deployment. The future of modular development is here! 🎉