import Foundation

/// # Intent Parser
///
/// Parses natural language development requests into structured build instructions.
///
/// ## Overview
///
/// The Intent Parser is the brain of the Granular Development Intelligence System.
/// It converts requests like "add Feature21 to Dashboard" into specific build targets
/// and scope limitations to prevent unnecessary rebuilds.
///
/// ## Topics
///
/// ### Parsing
/// - ``parseRequest(_:)``
/// - ``extractTarget(from:)``
/// - ``determineAction(from:)``
/// - ``identifyScope(for:action:)``
///
/// ### Pattern Matching
/// - ``ActionPattern``
/// - ``TargetPattern``
/// - ``ScopePattern``
///
/// ## Usage
///
/// ```swift
/// let parser = IntentParser()
/// let instructions = parser.parseRequest("fix the Add Module button")
/// // Result: BuildInstructions(
/// //   target: "ui.sidebar.addModule",
/// //   scope: .component,
/// //   action: .fix,
/// //   files: ["Platforms/macOS/BridgeMac.swift"]
/// // )
/// ```
public class IntentParser {
    
    /// Component mapping database
    private let componentMap: ComponentMap
    
    /// Action patterns for natural language processing
    private let actionPatterns: [ActionPattern] = [
        ActionPattern(keywords: ["fix", "repair", "correct"], action: .fix),
        ActionPattern(keywords: ["add", "create", "implement", "build"], action: .add),
        ActionPattern(keywords: ["enhance", "improve", "upgrade", "extend"], action: .enhance),
        ActionPattern(keywords: ["remove", "delete", "clean"], action: .remove),
        ActionPattern(keywords: ["update", "modify", "change"], action: .update)
    ]
    
    /// Target patterns for identifying components
    private let targetPatterns: [TargetPattern] = [
        TargetPattern(keywords: ["button", "btn"], type: .uiComponent),
        TargetPattern(keywords: ["module", "component"], type: .module),
        TargetPattern(keywords: ["widget", "tile", "card"], type: .submodule),
        TargetPattern(keywords: ["sidebar", "navigation", "nav"], type: .navigation),
        TargetPattern(keywords: ["dashboard", "home"], type: .module),
        TargetPattern(keywords: ["projects", "project"], type: .module),
        TargetPattern(keywords: ["terminal", "console"], type: .module)
    ]
    
    /// Initialize with component mapping
    public init() {
        self.componentMap = ComponentMap()
    }
    
    /// Parse development request into build instructions
    ///
    /// - Parameter request: Natural language request
    /// - Returns: Structured build instructions
    ///
    /// ## Examples
    ///
    /// ```swift
    /// parser.parseRequest("add Feature21 to Dashboard")
    /// // Target: dashboard.features.feature21, Scope: submodule
    ///
    /// parser.parseRequest("fix the Add Module button")
    /// // Target: ui.sidebar.addModule, Scope: component
    ///
    /// parser.parseRequest("enhance stats widget with real-time data")
    /// // Target: dashboard.widgets.stats, Scope: submodule
    ///
    /// parser.parseRequest("create new sidebar tile for system status")
    /// // Target: ui.sidebar.systemStatus, Scope: component
    /// ```
    public func parseRequest(_ request: String) -> BuildInstructions {
        let normalizedRequest = request.lowercased()
        
        // Extract action
        let action = determineAction(from: normalizedRequest)
        
        // Extract target
        let target = extractTarget(from: normalizedRequest)
        
        // Determine scope based on target and action
        let scope = identifyScope(for: target, action: action)
        
        // Get component details from map
        let componentDetails = componentMap.getComponent(for: target)
        
        // Build instructions
        return BuildInstructions(
            target: target,
            scope: scope,
            action: action,
            files: componentDetails?.files ?? [],
            preserve: determinePreserveList(for: scope, target: target),
            tests: componentDetails?.testFiles ?? [],
            estimatedTime: componentDetails?.buildTime ?? 60,
            hotSwappable: componentDetails?.hotSwappable ?? false
        )
    }
    
    /// Extract target component from request
    private func extractTarget(from request: String) -> String {
        // Check for specific component mentions
        if request.contains("add module") {
            return "ui.sidebar.addModule"
        }
        
        if request.contains("sidebar") && request.contains("navigation") {
            return "ui.navigation.sidebar"
        }
        
        if request.contains("dashboard") {
            if request.contains("stats") || request.contains("statistics") {
                return "dashboard.widgets.stats"
            }
            if request.contains("activity") || request.contains("feed") {
                return "dashboard.widgets.activity"
            }
            if request.contains("actions") || request.contains("quick") {
                return "dashboard.widgets.actions"
            }
            if request.contains("health") || request.contains("system") {
                return "dashboard.widgets.health"
            }
            return "module.dashboard"
        }
        
        if request.contains("projects") {
            return "module.projects"
        }
        
        if request.contains("terminal") {
            return "module.terminal"
        }
        
        // Handle new component creation
        if request.contains("new") || request.contains("create") {
            if request.contains("tile") || request.contains("widget") {
                return generateNewComponentIdentifier(from: request)
            }
        }
        
        // Default to general UI component
        return "ui.general.component"
    }
    
    /// Determine action from request
    private func determineAction(from request: String) -> BuildAction {
        for pattern in actionPatterns {
            for keyword in pattern.keywords {
                if request.contains(keyword) {
                    return pattern.action
                }
            }
        }
        return .update // Default action
    }
    
    /// Identify build scope based on target and action
    private func identifyScope(for target: String, action: BuildAction) -> BuildScope {
        // UI components are always component scope
        if target.starts(with: "ui.") {
            return .component
        }
        
        // Dashboard widgets are submodule scope
        if target.starts(with: "dashboard.widgets.") {
            return .submodule
        }
        
        // Top-level modules
        if target.starts(with: "module.") {
            return .module
        }
        
        // Core components are system scope
        if target.starts(with: "core.") {
            return .system
        }
        
        // Default based on action
        switch action {
        case .add where target.contains("."):
            return .submodule
        case .fix:
            return .component
        default:
            return .component
        }
    }
    
    /// Determine what to preserve based on scope
    private func determinePreserveList(for scope: BuildScope, target: String) -> [String] {
        switch scope {
        case .component:
            // Preserve everything except the specific component
            return ["modules/*", "core/*", "ui/*"].filter { !$0.contains(target) }
        case .submodule:
            // Preserve all other modules and submodules
            return ["modules/*", "core/*"]
        case .module:
            // Preserve all other modules
            let moduleId = target.replacingOccurrences(of: "module.", with: "")
            return ["modules/*"].filter { !$0.contains(moduleId) }
        case .system:
            // Preserve modules, only update core
            return ["modules/*"]
        case .full:
            // Nothing preserved in full rebuild
            return []
        }
    }
    
    /// Generate identifier for new component
    private func generateNewComponentIdentifier(from request: String) -> String {
        // Extract the component name
        if request.contains("system status") {
            return "ui.sidebar.systemStatus"
        }
        
        // More patterns can be added here
        return "ui.new.component"
    }
}

/// # Build Instructions
///
/// Structured instructions for executing a build based on parsed intent.
public struct BuildInstructions {
    /// Target component identifier
    public let target: String
    
    /// Build scope level
    public let scope: BuildScope
    
    /// Action to perform
    public let action: BuildAction
    
    /// Files to modify or create
    public let files: [String]
    
    /// Components to preserve unchanged
    public let preserve: [String]
    
    /// Tests to run after build
    public let tests: [String]
    
    /// Estimated build time in seconds
    public let estimatedTime: Int
    
    /// Whether component supports hot-swapping
    public let hotSwappable: Bool
}

/// # Build Scope
///
/// Defines the scope of changes for a build operation.
public enum BuildScope: String {
    /// Single UI element or function
    case component
    
    /// Feature within a module
    case submodule
    
    /// Entire module
    case module
    
    /// Core architecture
    case system
    
    /// Complete rebuild (rare)
    case full
    
    /// Human-readable description
    public var description: String {
        switch self {
        case .component:
            return "Single component build"
        case .submodule:
            return "Submodule build"
        case .module:
            return "Module build"
        case .system:
            return "System architecture build"
        case .full:
            return "Full application rebuild"
        }
    }
}

/// # Build Action
///
/// The type of modification to perform.
public enum BuildAction: String {
    /// Fix existing functionality
    case fix
    
    /// Add new functionality
    case add
    
    /// Enhance existing functionality
    case enhance
    
    /// Remove functionality
    case remove
    
    /// General update
    case update
}

/// # Action Pattern
///
/// Pattern matching for action keywords.
struct ActionPattern {
    let keywords: [String]
    let action: BuildAction
}

/// # Target Pattern
///
/// Pattern matching for target identification.
struct TargetPattern {
    let keywords: [String]
    let type: ComponentType
}

/// # Component Type
///
/// Type of component for pattern matching.
enum ComponentType {
    case uiComponent
    case module
    case submodule
    case navigation
    case core
}

/// # Component Map
///
/// Loads and provides access to component mapping database.
class ComponentMap {
    private var components: [String: ComponentDetails] = [:]
    
    init() {
        loadComponentMap()
    }
    
    /// Load component map from JSON
    private func loadComponentMap() {
        // In production, load from component-map.json
        // For now, provide hardcoded mapping
        components = [
            "ui.sidebar.addModule": ComponentDetails(
                files: ["Platforms/macOS/BridgeMac.swift"],
                testFiles: ["Tests/UI/ModuleSelectorTests.swift"],
                buildTime: 30,
                hotSwappable: true
            ),
            "ui.navigation.sidebar": ComponentDetails(
                files: ["Platforms/macOS/BridgeMac.swift"],
                testFiles: ["Tests/UI/SidebarNavigationTests.swift"],
                buildTime: 45,
                hotSwappable: true
            ),
            "dashboard.widgets.stats": ComponentDetails(
                files: ["Modules/Dashboard/SubModules/StatsWidget/", "Core/MockModules.swift"],
                testFiles: ["Tests/Modules/Dashboard/StatsWidgetTests.swift"],
                buildTime: 60,
                hotSwappable: true
            ),
            "module.dashboard": ComponentDetails(
                files: ["Modules/Dashboard/Sources/DashboardModule.swift", "Core/MockModules.swift"],
                testFiles: ["Tests/Modules/DashboardTests.swift"],
                buildTime: 120,
                hotSwappable: true
            )
        ]
    }
    
    /// Get component details
    func getComponent(for identifier: String) -> ComponentDetails? {
        return components[identifier]
    }
}

/// Component details from mapping
struct ComponentDetails {
    let files: [String]
    let testFiles: [String]
    let buildTime: Int
    let hotSwappable: Bool
}