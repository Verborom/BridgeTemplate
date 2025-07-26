import Foundation

/// # Build Scope Analyzer
///
/// Determines what needs to be built based on requested changes.
///
/// ## Overview
///
/// The Scope Analyzer examines build instructions and determines the complete
/// set of components that need to be rebuilt, including dependencies and
/// affected components. It ensures builds are minimal yet complete.
///
/// ## Topics
///
/// ### Analysis
/// - ``analyzeImpact(_:)``
/// - ``checkDependencies(_:)``
/// - ``determineBuildOrder(_:)``
///
/// ### Optimization
/// - ``optimizeBuildPlan(_:)``
/// - ``canHotSwap(_:)``
/// - ``requiresFullRebuild(_:)``
///
/// ## Usage
///
/// ```swift
/// let analyzer = ScopeAnalyzer()
/// let plan = analyzer.analyzeImpact(instructions)
/// // Returns optimized build plan with minimal scope
/// ```
public class ScopeAnalyzer {
    
    /// Component dependency graph
    private var dependencyGraph: [String: Set<String>] = [:]
    
    /// Reverse dependency graph (what depends on this)
    private var reverseDependencyGraph: [String: Set<String>] = [:]
    
    /// Component map for lookups
    private let componentMap: ComponentMap
    
    /// Initialize analyzer
    public init() {
        self.componentMap = ComponentMap()
        buildDependencyGraphs()
    }
    
    /// Analyze what components are affected by a change
    ///
    /// - Parameter instructions: Build instructions from intent parser
    /// - Returns: Complete build plan with all affected components
    ///
    /// ## Algorithm
    ///
    /// 1. Start with primary target
    /// 2. Find all direct dependencies
    /// 3. Find all components that depend on target
    /// 4. Determine minimal build set
    /// 5. Calculate build order
    /// 6. Estimate total build time
    public func analyzeImpact(_ instructions: BuildInstructions) -> BuildPlan {
        var affectedComponents = Set<String>()
        var testsToRun = Set<String>()
        var documentsToUpdate = Set<String>()
        
        // Add primary target
        affectedComponents.insert(instructions.target)
        testsToRun.formUnion(instructions.tests)
        
        // Check dependencies based on scope
        switch instructions.scope {
        case .component:
            // Component changes rarely affect others
            let directDependents = getDirectDependents(of: instructions.target)
            if !directDependents.isEmpty {
                print("⚠️ Component has dependents: \(directDependents)")
                affectedComponents.formUnion(directDependents)
            }
            
        case .submodule:
            // Submodule changes might affect parent module
            if let parentModule = getParentModule(of: instructions.target) {
                affectedComponents.insert(parentModule)
                testsToRun.insert("\(parentModule)Tests")
            }
            
        case .module:
            // Module changes affect all submodules
            let submodules = getSubmodules(of: instructions.target)
            affectedComponents.formUnion(submodules)
            
            // Check module dependencies
            let dependents = getAllDependents(of: instructions.target)
            affectedComponents.formUnion(dependents)
            
        case .system:
            // System changes affect many components
            let allDependents = getAllSystemDependents(of: instructions.target)
            affectedComponents.formUnion(allDependents)
            
        case .full:
            // Full rebuild affects everything
            return BuildPlan(
                primaryTarget: instructions.target,
                dependentComponents: [],
                testsToRun: ["all"],
                documentsToUpdate: ["all"],
                estimatedBuildTime: 300,
                buildOrder: ["full"],
                canHotSwap: false,
                requiresRestart: true
            )
        }
        
        // Determine documents to update
        if instructions.action == .add || instructions.action == .enhance {
            documentsToUpdate.insert("\(instructions.target).md")
            documentsToUpdate.insert("component-map.json")
        }
        
        // Calculate build order
        let buildOrder = determineBuildOrder(Array(affectedComponents))
        
        // Estimate total build time
        let estimatedTime = calculateTotalBuildTime(for: Array(affectedComponents))
        
        // Check if hot-swappable
        let canHotSwap = affectedComponents.allSatisfy { component in
            componentMap.getComponent(for: component)?.hotSwappable ?? false
        }
        
        // Check if restart required
        let requiresRestart = instructions.scope == .system || 
                              affectedComponents.contains { $0.starts(with: "core.") }
        
        return BuildPlan(
            primaryTarget: instructions.target,
            dependentComponents: Array(affectedComponents.subtracting([instructions.target])),
            testsToRun: Array(testsToRun),
            documentsToUpdate: Array(documentsToUpdate),
            estimatedBuildTime: estimatedTime,
            buildOrder: buildOrder,
            canHotSwap: canHotSwap && instructions.hotSwappable,
            requiresRestart: requiresRestart
        )
    }
    
    /// Check for cross-module dependencies
    ///
    /// - Parameter target: Component identifier
    /// - Returns: List of dependencies
    public func checkDependencies(_ target: String) -> [String] {
        return Array(dependencyGraph[target] ?? [])
    }
    
    /// Optimize build plan to minimize work
    ///
    /// - Parameter plan: Initial build plan
    /// - Returns: Optimized build plan
    public func optimizeBuildPlan(_ plan: BuildPlan) -> BuildPlan {
        var optimized = plan
        
        // Remove redundant builds
        if plan.canHotSwap && plan.dependentComponents.isEmpty {
            // Single component hot-swap is fastest
            optimized.estimatedBuildTime = min(30, plan.estimatedBuildTime)
        }
        
        // Parallelize where possible
        let parallelizableComponents = identifyParallelizable(plan.buildOrder)
        if parallelizableComponents.count > 1 {
            // Reduce time for parallel builds
            optimized.estimatedBuildTime = Int(Double(plan.estimatedBuildTime) * 0.7)
        }
        
        return optimized
    }
    
    /// Check if component can be hot-swapped
    ///
    /// - Parameter component: Component identifier
    /// - Returns: true if hot-swappable
    public func canHotSwap(_ component: String) -> Bool {
        // System components cannot be hot-swapped
        if component.starts(with: "core.") {
            return false
        }
        
        // Check component map
        return componentMap.getComponent(for: component)?.hotSwappable ?? false
    }
    
    /// Check if changes require full rebuild
    ///
    /// - Parameter instructions: Build instructions
    /// - Returns: true if full rebuild required
    public func requiresFullRebuild(_ instructions: BuildInstructions) -> Bool {
        // Protocol changes require full rebuild
        if instructions.target == "core.bridgeModule" {
            return true
        }
        
        // Major version changes might require full rebuild
        if instructions.action == .update && instructions.scope == .system {
            return true
        }
        
        return false
    }
    
    // MARK: - Private Methods
    
    /// Build dependency graphs
    private func buildDependencyGraphs() {
        // UI dependencies
        dependencyGraph["ui.sidebar.addModule"] = ["moduleManager"]
        dependencyGraph["ui.navigation.sidebar"] = ["navigationController"]
        dependencyGraph["ui.sidebar.moduleRow"] = ["moduleManager"]
        
        // Module dependencies
        dependencyGraph["module.projects"] = ["module.dashboard"]
        dependencyGraph["dashboard.widgets.stats"] = ["module.dashboard"]
        dependencyGraph["dashboard.widgets.activity"] = ["module.dashboard"]
        
        // Build reverse graph
        for (component, dependencies) in dependencyGraph {
            for dependency in dependencies {
                reverseDependencyGraph[dependency, default: []].insert(component)
            }
        }
    }
    
    /// Get direct dependents of a component
    private func getDirectDependents(of component: String) -> Set<String> {
        return reverseDependencyGraph[component] ?? []
    }
    
    /// Get all transitive dependents
    private func getAllDependents(of component: String) -> Set<String> {
        var visited = Set<String>()
        var toVisit = [component]
        var dependents = Set<String>()
        
        while !toVisit.isEmpty {
            let current = toVisit.removeFirst()
            if visited.contains(current) { continue }
            visited.insert(current)
            
            if let directDependents = reverseDependencyGraph[current] {
                dependents.formUnion(directDependents)
                toVisit.append(contentsOf: directDependents)
            }
        }
        
        return dependents
    }
    
    /// Get parent module of a submodule
    private func getParentModule(of submodule: String) -> String? {
        if submodule.starts(with: "dashboard.widgets.") {
            return "module.dashboard"
        }
        return nil
    }
    
    /// Get submodules of a module
    private func getSubmodules(of module: String) -> Set<String> {
        switch module {
        case "module.dashboard":
            return ["dashboard.widgets.stats", "dashboard.widgets.activity", 
                    "dashboard.widgets.actions", "dashboard.widgets.health"]
        default:
            return []
        }
    }
    
    /// Get all system dependents
    private func getAllSystemDependents(of component: String) -> Set<String> {
        if component.starts(with: "core.") {
            // Core changes affect all modules
            return ["module.dashboard", "module.projects", "module.terminal"]
        }
        return []
    }
    
    /// Determine build order respecting dependencies
    private func determineBuildOrder(_ components: [String]) -> [String] {
        // Simple topological sort
        var sorted: [String] = []
        var visited = Set<String>()
        
        func visit(_ component: String) {
            if visited.contains(component) { return }
            visited.insert(component)
            
            // Visit dependencies first
            if let deps = dependencyGraph[component] {
                for dep in deps {
                    if components.contains(dep) {
                        visit(dep)
                    }
                }
            }
            
            sorted.append(component)
        }
        
        for component in components {
            visit(component)
        }
        
        return sorted
    }
    
    /// Calculate total build time
    private func calculateTotalBuildTime(for components: [String]) -> Int {
        return components.reduce(0) { total, component in
            let componentTime = componentMap.getComponent(for: component)?.buildTime ?? 60
            return total + componentTime
        }
    }
    
    /// Identify components that can be built in parallel
    private func identifyParallelizable(_ buildOrder: [String]) -> [[String]] {
        // Group components with no inter-dependencies
        // Simplified for now
        return buildOrder.map { [$0] }
    }
}

/// # Build Plan
///
/// Complete plan for executing a build with all affected components.
public struct BuildPlan {
    /// Primary target component
    public let primaryTarget: String
    
    /// Components that depend on primary target
    public let dependentComponents: [String]
    
    /// Tests that should be run
    public let testsToRun: [String]
    
    /// Documents that need updating
    public let documentsToUpdate: [String]
    
    /// Total estimated build time in seconds
    public let estimatedBuildTime: Int
    
    /// Order in which to build components
    public let buildOrder: [String]
    
    /// Whether changes can be hot-swapped
    public let canHotSwap: Bool
    
    /// Whether app restart is required
    public let requiresRestart: Bool
    
    /// Human-readable summary
    public var summary: String {
        let componentCount = dependentComponents.count + 1
        let timeString = estimatedBuildTime < 60 ? "\(estimatedBuildTime) seconds" : "\(estimatedBuildTime / 60) minutes"
        let hotSwapString = canHotSwap ? "hot-swappable" : "requires reload"
        
        return """
        Build Plan:
        - Target: \(primaryTarget)
        - Affected Components: \(componentCount)
        - Estimated Time: \(timeString)
        - Mode: \(hotSwapString)
        - Tests: \(testsToRun.count)
        """
    }
}