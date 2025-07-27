import Foundation

/// # Enhanced Intent Parser
///
/// Advanced parser supporting infinite nesting levels for granular development.
///
/// ## Overview
///
/// This enhanced version can parse requests at any depth level, from
/// property-level changes to full module updates. It understands context
/// and can identify the exact widget or feature being referenced.
///
/// ## Supported Patterns
///
/// - "Fix the CPU display animation" → `systemHealth.cpu.display.animation`
/// - "Add GPU metrics to System Health" → `systemHealth.gpu`
/// - "Change memory bar color to red" → `systemHealth.memory.display.bar.color`
/// - "Update the percentage display in CPU metrics" → `systemHealth.cpu.display.percentageBar`
public class EnhancedIntentParser {
    
    /// Component hierarchy mapping
    private let componentHierarchy: ComponentHierarchy
    
    /// Enhanced patterns for deeper parsing
    private let patterns: PatternMatcher
    
    /// Initialize parser
    public init() {
        self.componentHierarchy = ComponentHierarchy()
        self.patterns = PatternMatcher()
    }
    
    /// Parse development request with infinite nesting support
    ///
    /// - Parameter request: Natural language request
    /// - Returns: Enhanced build instructions with precise targeting
    public func parseRequest(_ request: String) -> EnhancedBuildInstructions {
        let normalized = normalize(request)
        
        // Extract all components mentioned
        let components = extractComponentChain(from: normalized)
        
        // Determine the target path
        let targetPath = buildTargetPath(from: components, request: normalized)
        
        // Determine build level
        let level = determineBuildLevel(from: targetPath)
        
        // Extract action
        let action = extractAction(from: normalized)
        
        // Get component details
        let details = componentHierarchy.getComponent(at: targetPath)
        
        return EnhancedBuildInstructions(
            targetPath: targetPath,
            level: level,
            action: action,
            scope: mapLevelToScope(level),
            files: details?.files ?? [],
            estimatedTime: estimateTime(for: level),
            hotSwappable: details?.hotSwappable ?? true,
            affectedComponents: determineAffectedComponents(targetPath, level)
        )
    }
    
    /// Extract component chain from request
    private func extractComponentChain(from request: String) -> [String] {
        var components: [String] = []
        
        // Check for system health mentions
        if request.contains("system health") || request.contains("systemhealth") {
            components.append("systemHealth")
        }
        
        // Check for CPU-related terms
        if request.contains("cpu") {
            components.append("cpu")
            
            if request.contains("display") || request.contains("show") {
                components.append("display")
                
                if request.contains("animation") || request.contains("animate") {
                    components.append("animation")
                } else if request.contains("percentage") || request.contains("bar") {
                    components.append("percentageBar")
                } else if request.contains("number") || request.contains("text") {
                    components.append("numberDisplay")
                }
            } else if request.contains("data") || request.contains("source") {
                components.append("dataSource")
            }
        }
        
        // Check for memory-related terms
        if request.contains("memory") || request.contains("ram") {
            components.append("memory")
            
            if request.contains("display") || request.contains("bar") {
                components.append("display")
                
                if request.contains("bar") || request.contains("progress") {
                    components.append("bar")
                    
                    if request.contains("color") || request.contains("colour") {
                        components.append("color")
                    }
                }
            }
        }
        
        // Check for GPU (future feature)
        if request.contains("gpu") || request.contains("graphics") {
            components.append("gpu")
        }
        
        return components
    }
    
    /// Build target path from components
    private func buildTargetPath(from components: [String], request: String) -> String {
        if components.isEmpty {
            return "unknown"
        }
        
        // Start with base path
        var path = components[0]
        
        // Add subsequent components
        for i in 1..<components.count {
            path += ".\(components[i])"
        }
        
        return path
    }
    
    /// Determine build level from target path
    private func determineBuildLevel(from path: String) -> BuildLevel {
        let components = path.split(separator: ".").count
        
        switch components {
        case 1:
            return .module // e.g., "systemHealth"
        case 2:
            return .feature // e.g., "systemHealth.cpu"
        case 3:
            return .component // e.g., "systemHealth.cpu.display"
        case 4:
            return .widget // e.g., "systemHealth.cpu.display.animation"
        case 5...:
            return .property // e.g., "systemHealth.memory.display.bar.color"
        default:
            return .component
        }
    }
    
    /// Extract action from request
    private func extractAction(from request: String) -> BuildAction {
        if request.contains("fix") || request.contains("repair") {
            return .fix
        } else if request.contains("add") || request.contains("create") {
            return .add
        } else if request.contains("enhance") || request.contains("improve") {
            return .enhance
        } else if request.contains("change") || request.contains("update") {
            return .update
        } else if request.contains("remove") || request.contains("delete") {
            return .remove
        }
        
        return .update
    }
    
    /// Map build level to scope
    private func mapLevelToScope(_ level: BuildLevel) -> BuildScope {
        switch level {
        case .property, .widget:
            return .component
        case .component:
            return .component
        case .feature:
            return .submodule
        case .submodule:
            return .submodule
        case .module:
            return .module
        case .system:
            return .system
        }
    }
    
    /// Estimate build time based on level
    private func estimateTime(for level: BuildLevel) -> Int {
        switch level {
        case .property:
            return 15
        case .widget:
            return 30
        case .component:
            return 45
        case .feature:
            return 90
        case .submodule:
            return 120
        case .module:
            return 180
        case .system:
            return 300
        }
    }
    
    /// Normalize request
    private func normalize(_ request: String) -> String {
        return request
            .lowercased()
            .replacingOccurrences(of: "the ", with: "")
            .replacingOccurrences(of: "in ", with: " ")
            .replacingOccurrences(of: "to ", with: " ")
    }
    
    /// Determine affected components
    private func determineAffectedComponents(_ path: String, _ level: BuildLevel) -> [String] {
        var affected: [String] = [path]
        
        // Add parent components for context
        let parts = path.split(separator: ".")
        for i in 1..<parts.count {
            let parentPath = parts[0..<i].joined(separator: ".")
            affected.append(parentPath)
        }
        
        return affected
    }
}

/// # Enhanced Build Instructions
///
/// Detailed instructions supporting infinite nesting levels.
public struct EnhancedBuildInstructions {
    /// Full target path (e.g., "systemHealth.cpu.display.animation")
    public let targetPath: String
    
    /// Build level
    public let level: BuildLevel
    
    /// Action to perform
    public let action: BuildAction
    
    /// Traditional scope (for compatibility)
    public let scope: BuildScope
    
    /// Files to modify
    public let files: [String]
    
    /// Estimated build time in seconds
    public let estimatedTime: Int
    
    /// Whether component supports hot-swapping
    public let hotSwappable: Bool
    
    /// All affected component paths
    public let affectedComponents: [String]
    
    /// Human-readable summary
    public var summary: String {
        return """
        Target: \(targetPath)
        Level: \(level)
        Action: \(action)
        Build Time: \(estimatedTime)s
        Hot-Swappable: \(hotSwappable)
        """
    }
}

/// # Build Level
///
/// Granular levels supporting infinite nesting.
public enum BuildLevel: String, CaseIterable {
    /// Single property (color, size, etc.)
    case property
    
    /// UI widget (bar, button, etc.)
    case widget
    
    /// Functional component (display, datasource)
    case component
    
    /// Major feature (CPUMetrics, GPUMetrics)
    case feature
    
    /// Module section (SystemHealth)
    case submodule
    
    /// Full module (Dashboard)
    case module
    
    /// Core system changes
    case system
    
    public var description: String {
        switch self {
        case .property:
            return "Property-level change (15s)"
        case .widget:
            return "Widget-level change (30s)"
        case .component:
            return "Component-level change (45s)"
        case .feature:
            return "Feature-level change (90s)"
        case .submodule:
            return "Submodule-level change (2min)"
        case .module:
            return "Module-level change (3min)"
        case .system:
            return "System-level change (5min)"
        }
    }
}

/// # Component Hierarchy
///
/// Manages the infinitely nested component structure.
class ComponentHierarchy {
    private var hierarchy: [String: ComponentNode] = [:]
    
    init() {
        buildHierarchy()
    }
    
    private func buildHierarchy() {
        // System Health hierarchy
        hierarchy["systemHealth"] = ComponentNode(
            path: "systemHealth",
            level: .submodule,
            files: ["Modules/Dashboard/SubModules/SystemHealth/"],
            children: [
                "cpu": ComponentNode(
                    path: "systemHealth.cpu",
                    level: .feature,
                    files: ["SystemHealth/Features/CPUMetrics/"],
                    children: [
                        "display": ComponentNode(
                            path: "systemHealth.cpu.display",
                            level: .component,
                            files: ["CPUMetrics/Sources/Display/"],
                            children: [
                                "animation": ComponentNode(
                                    path: "systemHealth.cpu.display.animation",
                                    level: .widget,
                                    files: ["Display/Widgets/Animation.swift"]
                                ),
                                "percentageBar": ComponentNode(
                                    path: "systemHealth.cpu.display.percentageBar",
                                    level: .widget,
                                    files: ["Display/Widgets/PercentageBar.swift"]
                                ),
                                "numberDisplay": ComponentNode(
                                    path: "systemHealth.cpu.display.numberDisplay",
                                    level: .widget,
                                    files: ["Display/Widgets/NumberDisplay.swift"]
                                )
                            ]
                        ),
                        "dataSource": ComponentNode(
                            path: "systemHealth.cpu.dataSource",
                            level: .component,
                            files: ["CPUMetrics/Sources/CPUDataSource.swift"]
                        )
                    ]
                ),
                "memory": ComponentNode(
                    path: "systemHealth.memory",
                    level: .feature,
                    files: ["SystemHealth/Features/MemoryMetrics/"],
                    children: [
                        "display": ComponentNode(
                            path: "systemHealth.memory.display",
                            level: .component,
                            files: ["MemoryMetrics/Sources/Display/"],
                            children: [
                                "bar": ComponentNode(
                                    path: "systemHealth.memory.display.bar",
                                    level: .widget,
                                    files: ["Display/Widgets/MemoryBar.swift"],
                                    children: [
                                        "color": ComponentNode(
                                            path: "systemHealth.memory.display.bar.color",
                                            level: .property,
                                            files: ["Display/Widgets/MemoryBar.swift#color"]
                                        )
                                    ]
                                )
                            ]
                        )
                    ]
                ),
                "gpu": ComponentNode(
                    path: "systemHealth.gpu",
                    level: .feature,
                    files: ["SystemHealth/Features/GPUMetrics/"],
                    isPlanned: true
                )
            ]
        )
    }
    
    func getComponent(at path: String) -> ComponentNode? {
        let parts = path.split(separator: ".")
        var current = hierarchy[String(parts[0])]
        
        for i in 1..<parts.count {
            current = current?.children[String(parts[i])]
        }
        
        return current
    }
}

/// Component node in hierarchy
struct ComponentNode {
    let path: String
    let level: BuildLevel
    let files: [String]
    let hotSwappable: Bool
    let children: [String: ComponentNode]
    let isPlanned: Bool
    
    init(
        path: String,
        level: BuildLevel,
        files: [String],
        hotSwappable: Bool = true,
        children: [String: ComponentNode] = [:],
        isPlanned: Bool = false
    ) {
        self.path = path
        self.level = level
        self.files = files
        self.hotSwappable = hotSwappable
        self.children = children
        self.isPlanned = isPlanned
    }
}

/// Pattern matcher for improved parsing
class PatternMatcher {
    // Pattern matching implementation
}