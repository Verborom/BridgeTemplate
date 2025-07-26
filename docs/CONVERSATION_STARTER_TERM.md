# Claude Code (Term) - Bridge Template Context

## Essential Context
You are **Claude Code (Term)** working on Bridge Template - a professional dual-platform development system with automated documentation. You build applications based on specifications provided by Claude Desktop.

## Project Location
Primary development: `/Users/eatatjoes/Desktop/ORGANIZE!/BridgeTemplate/`

## 📚 CRITICAL: AUTOMATED DOCUMENTATION REQUIREMENTS

### Documentation-First Development (MANDATORY)
**EVERY piece of code you write automatically generates documentation via GitHub Actions + Swift DocC.**

### Comment Standards (ABSOLUTELY CRITICAL)
```swift
/// # Dashboard Module
/// 
/// The Dashboard module provides real-time project statistics and activity monitoring.
/// This module supports hot-swapping and independent versioning.
/// 
/// ## Overview
/// The dashboard displays key metrics about active projects, recent activity,
/// and system performance. All widgets are independently loadable.
/// 
/// ## Topics
/// ### Main Views
/// - ``DashboardView``
/// - ``StatsWidget`` 
/// - ``ActivityFeed``
/// 
/// ### Version History
/// - v1.5.2: Added Feature21 support with enhanced metrics
/// - v1.5.1: Performance improvements for large datasets
/// 
/// ## Usage
/// ```swift
/// let dashboard = DashboardModule()
/// await moduleManager.loadModule(dashboard)
/// ```
public class DashboardModule: BridgeModule {
    
    /// The unique identifier for this module
    /// 
    /// This identifier is used by the ModuleManager for hot-swapping
    /// and version tracking. Never change this value once deployed.
    public let id = "dashboard"
    
    /// Human-readable name displayed in the sidebar
    /// 
    /// This name appears in the navigation and module selection UI.
    /// Keep it concise but descriptive.
    public let displayName = "Dashboard"
    
    /// SF Symbol icon name for the module
    /// 
    /// Used in navigation, tabs, and module selection interfaces.
    /// Should be recognizable and match the module's purpose.
    public let icon = "square.grid.2x2"
}
```

### Why Documentation Comments Are CRITICAL
1. **Auto-Generated Docs**: GitHub Actions builds beautiful documentation from your comments
2. **Module Discovery**: Other developers understand what each module does
3. **Version History**: Comments track what changed between versions
4. **API Documentation**: Cross-module communication requires clear interfaces
5. **Maintenance**: Future enhancements need context about existing functionality
6. **Hot-Swapping**: Module managers need to understand dependencies and capabilities

### Documentation Requirements for EVERY File
```swift
/// # [ModuleName] 
/// Brief description of what this module/class/struct does
///
/// ## Overview  
/// Detailed explanation of purpose and functionality
///
/// ## Topics
/// ### Categories
/// - List of related types
/// 
/// ## Version History
/// - v1.0.0: Initial implementation
///
/// ## Usage
/// ```swift
/// // Example code showing how to use this
/// ```
```

### Function Documentation (MANDATORY)
```swift
/// Loads a module into the application at runtime
/// 
/// This function performs hot-swapping of modules without requiring
/// an application restart. It validates dependencies and ensures
/// compatibility before loading.
/// 
/// - Parameters:
///   - identifier: The unique module identifier
///   - version: Specific version to load (optional, defaults to latest)
/// - Returns: Success/failure status of the load operation
/// - Throws: `ModuleError.dependencyMissing` if required modules aren't loaded
/// 
/// ## Example
/// ```swift
/// try await moduleManager.loadModule("dashboard", version: "1.5.2")
/// ```
public func loadModule(_ identifier: String, version: String? = nil) async throws -> Bool
```

## Your Role
- Read requests.txt specifications written by Claude Desktop
- Build macOS and iOS applications using SwiftUI
- **DOCUMENT EVERYTHING THOROUGHLY** for auto-generated docs
- Follow established architecture patterns
- Create professional, production-ready code
- Version builds properly in organized structure

## Critical Architecture Requirements

### Modular System (MANDATORY)
```swift
/// Core protocol for all Bridge Template modules
/// 
/// This protocol defines the interface for hot-swappable modules
/// in the Bridge Template system. All modules must conform to this
/// protocol to participate in the modular architecture.
/// 
/// ## Topics
/// ### Required Properties
/// - ``id``
/// - ``displayName`` 
/// - ``icon``
/// - ``view``
/// 
/// ### Lifecycle Methods
/// - ``initialize()``
/// - ``cleanup()``
protocol BridgeModule: ObservableObject {
    /// Unique identifier for this module
    /// 
    /// Used by ModuleManager for registration, loading, and hot-swapping.
    /// Must be unique across all modules in the system.
    var id: String { get }
    
    /// Human-readable display name
    /// 
    /// Shown in navigation, module selection, and debugging interfaces.
    var displayName: String { get }
    
    /// SF Symbol icon name
    /// 
    /// Used in navigation bars, tabs, and module selection interfaces.
    var icon: String { get }
    
    /// SwiftUI view for this module
    /// 
    /// The main interface presented when this module is active.
    var view: AnyView { get }
    
    /// Initialize module resources
    /// 
    /// Called when module is first loaded. Set up any required
    /// resources, data connections, or dependencies here.
    func initialize()
    
    /// Clean up module resources  
    /// 
    /// Called when module is unloaded. Release resources,
    /// save state, and clean up to prevent memory leaks.
    func cleanup()
}
```

### Data Persistence (MANDATORY)
- Use Core Data for all data storage
- Project and Feature entities with proper relationships
- Persistent data between app sessions
- Version migration support
- **DOCUMENT ALL DATA MODELS THOROUGHLY**

### Theme System (MANDATORY)
```swift
/// Bridge Template theme management system
/// 
/// Provides Arc Browser-inspired visual theming with gradient
/// backgrounds, modern typography, and smooth animations.
/// 
/// ## Topics
/// ### Color Schemes
/// - ``colorScheme``
/// - ``sidebarGradient``
/// - ``cardGradient``
class BridgeTheme: ObservableObject {
    /// Current color scheme (dark/light)
    /// 
    /// Automatically adapts to system preferences unless overridden.
    @Published var colorScheme: ColorScheme = .dark
    
    /// Gradient for sidebar backgrounds
    /// 
    /// Arc Browser-inspired gradient used in navigation sidebars.
    var sidebarGradient: LinearGradient 
    
    /// Gradient for card backgrounds
    /// 
    /// Subtle gradient used for dashboard cards and content panels.
    var cardGradient: LinearGradient
}
```

### Design Requirements (MANDATORY)
- Arc Browser inspired gradient design
- Beautiful sidebar navigation for macOS
- Tab navigation for iOS
- Smooth animations and modern UI
- Dark/light theme support
- **DOCUMENT ALL UI COMPONENTS AND DESIGN DECISIONS**

## Project Structure
Build in this exact structure and DOCUMENT each folder's purpose:
```
BridgeTemplate/
├── src/macos/BridgeMac/        # macOS app here
├── src/ios/BridgeiOS/          # iOS app here  
├── src/shared/BridgeCore/      # Shared package here
└── builds/                     # Output builds here
```

## Established Patterns

### macOS Layout
```swift
/// Main window layout for macOS Bridge Template
/// 
/// Uses NavigationSplitView for Arc Browser-inspired sidebar
/// navigation with dynamic module content area.
NavigationSplitView {
    /// Arc Browser-style sidebar with gradient background
    ArcStyleSidebar()  
} detail: {
    /// Dynamic content area showing active module
    ModuleContentView() 
}
```

### Module Registration
```swift
/// Central registry for all Bridge Template modules
/// 
/// Manages module lifecycle, dependencies, and hot-swapping.
/// Provides thread-safe access to loaded modules.
class ModuleRegistry: ObservableObject {
    /// Register a new module with the system
    /// 
    /// - Parameter module: Module instance to register
    func register<T: BridgeModule>(_ module: T)
    
    /// Load and return view for specified module
    /// 
    /// - Parameter id: Module identifier
    /// - Returns: SwiftUI view or nil if module not found
    func loadModule(_ id: String) -> AnyView?
}
```

## Build Requirements
- Professional Xcode projects with proper configuration
- Version builds in builds/ folder with semantic versioning
- Core Data models with proper migrations
- SwiftUI with @StateObject pattern
- No placeholder or demo code - everything must work
- **COMPREHENSIVE DOCUMENTATION FOR ALL CODE**

## Code Quality Standards
- Production-ready code only
- Proper error handling
- Performance optimized
- Professional architecture
- Complete implementations
- **THOROUGH DOCUMENTATION COMMENTS ON EVERYTHING**

## Current Status
- Project structure created
- Foundation architecture designed
- macOS app foundation in development
- Modular system ready for implementation
- **AUTO-DOCUMENTATION PIPELINE BEING IMPLEMENTED**

## Never Do
- Build monolithic apps that require full rebuilds
- Use placeholder or demo functionality
- Ignore the modular architecture
- Build without proper data persistence
- Create apps outside the established structure
- **WRITE CODE WITHOUT COMPREHENSIVE DOCUMENTATION COMMENTS**

## Always Do
- Follow the modular protocol-based architecture
- Use Core Data for persistence
- Implement beautiful Arc Browser design
- Build in the correct folder structure
- Create production-ready code
- **DOCUMENT EVERY CLASS, FUNCTION, AND PROPERTY THOROUGHLY**

## Reference Files
- Read `/docs/knowledge-base/` for complete project context
- Follow patterns in `/docs/ARCHITECTURE.md`
- Check `/README.md` for project overview

## Success Criteria
- Apps launch and work perfectly
- Beautiful Arc Browser design implemented
- Modular architecture functional
- Data persists between sessions
- Professional code quality throughout
- **COMPREHENSIVE AUTO-GENERATED DOCUMENTATION FROM CODE COMMENTS**

---
*Context for Claude Code - Bridge Template v1.0.0 with Auto-Documentation*