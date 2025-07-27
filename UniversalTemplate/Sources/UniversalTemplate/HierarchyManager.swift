import SwiftUI
import Combine

/// # HierarchyManager
///
/// Manages the complex relationships between components in the Bridge Template
/// hierarchy. This class handles parent-child relationships, dependency resolution,
/// and ensures the integrity of the component tree at all times.
///
/// ## Overview
///
/// HierarchyManager is the guardian of component relationships. It provides:
/// - **Relationship Management**: Add, remove, and move components in the hierarchy
/// - **Dependency Resolution**: Automatically resolve and validate dependencies
/// - **Circular Detection**: Prevent circular dependencies and infinite loops
/// - **Tree Operations**: Traverse, search, and manipulate the component tree
/// - **Event Propagation**: Bubble events up and broadcast down the hierarchy
/// - **Validation**: Ensure hierarchy rules are always maintained
///
/// ## Usage
///
/// ```swift
/// let manager = HierarchyManager()
/// 
/// // Add component to hierarchy
/// try await manager.addChild(newFeature, to: parentModule)
/// 
/// // Move component to new parent
/// try await manager.moveComponent(feature, to: newParent)
/// 
/// // Find components
/// let allFeatures = manager.findComponents(ofType: .feature)
/// 
/// // Validate entire hierarchy
/// let validation = try await manager.validateHierarchy(root)
/// ```
@MainActor
public final class HierarchyManager: ObservableObject {
    
    /// Hierarchy change notifications
    @Published public var lastChange: HierarchyChange?
    
    /// Validation errors
    @Published public var validationErrors: [ValidationError] = []
    
    /// Dependency graph
    private var dependencyGraph: DependencyGraph = DependencyGraph()
    
    /// Component registry for quick lookup
    private var componentRegistry: [UUID: any UniversalComponent] = [:]
    
    /// Hierarchy rules
    private var rules: [HierarchyRule] = []
    
    /// Public initializer
    public init() {
        setupDefaultRules()
    }
    
    // MARK: - Hierarchy Operations
    
    /// Add a child component to a parent
    ///
    /// - Parameters:
    ///   - child: Component to add
    ///   - parent: Parent component
    /// - Throws: HierarchyError if operation violates rules
    public func addChild(
        _ child: any UniversalComponent,
        to parent: any UniversalComponent
    ) async throws {
        // Validate operation
        try validateAddition(child: child, parent: parent)
        
        // Check for circular dependencies
        try checkCircularDependency(child: child, parent: parent)
        
        // Update relationships
        child.parent = parent
        parent.children.append(child)
        
        // Register component
        registerComponent(child)
        
        // Update dependency graph
        dependencyGraph.addNode(child)
        dependencyGraph.addEdge(from: parent.id, to: child.id)
        
        // Notify change
        notifyChange(.childAdded(parent: parent.id, child: child.id))
    }
    
    /// Remove a component from the hierarchy
    ///
    /// - Parameter component: Component to remove
    /// - Throws: HierarchyError if component cannot be removed
    public func removeComponent(_ component: any UniversalComponent) async throws {
        // Check if component can be removed
        guard component.canUnload() else {
            throw HierarchyError.cannotRemove("Component cannot be unloaded")
        }
        
        // Check dependents
        let dependents = findDependents(of: component)
        guard dependents.isEmpty else {
            throw HierarchyError.hasDependents(dependents.map { $0.id })
        }
        
        // Remove from parent
        if let parent = component.parent {
            parent.children.removeAll { $0.id == component.id }
        }
        
        // Remove all children recursively
        for child in component.children {
            try await removeComponent(child)
        }
        
        // Clear relationships
        component.parent = nil
        component.children.removeAll()
        
        // Unregister component
        unregisterComponent(component)
        
        // Update dependency graph
        dependencyGraph.removeNode(component.id)
        
        // Notify change
        notifyChange(.componentRemoved(component.id))
    }
    
    /// Move a component to a new parent
    ///
    /// - Parameters:
    ///   - component: Component to move
    ///   - newParent: New parent component
    /// - Throws: HierarchyError if move violates rules
    public func moveComponent(
        _ component: any UniversalComponent,
        to newParent: any UniversalComponent
    ) async throws {
        // Validate move
        try validateMove(component: component, to: newParent)
        
        // Remove from current parent
        if let currentParent = component.parent {
            currentParent.children.removeAll { $0.id == component.id }
            dependencyGraph.removeEdge(from: currentParent.id, to: component.id)
        }
        
        // Add to new parent
        component.parent = newParent
        newParent.children.append(component)
        dependencyGraph.addEdge(from: newParent.id, to: component.id)
        
        // Notify change
        notifyChange(.componentMoved(
            component: component.id,
            from: component.parent?.id,
            to: newParent.id
        ))
    }
    
    /// Reorder children of a component
    ///
    /// - Parameters:
    ///   - parent: Parent component
    ///   - orderedChildren: New order of children
    public func reorderChildren(
        of parent: any UniversalComponent,
        to orderedChildren: [any UniversalComponent]
    ) async throws {
        // Validate all children belong to parent
        let childIds = Set(parent.children.map { $0.id })
        let orderedIds = Set(orderedChildren.map { $0.id })
        
        guard childIds == orderedIds else {
            throw HierarchyError.invalidReorder("Child list mismatch")
        }
        
        // Update order
        parent.children = orderedChildren
        
        // Notify change
        notifyChange(.childrenReordered(parent: parent.id))
    }
    
    // MARK: - Dependency Management
    
    /// Add a dependency between components
    ///
    /// - Parameters:
    ///   - dependent: Component that depends on another
    ///   - dependency: Component being depended upon
    public func addDependency(
        from dependent: any UniversalComponent,
        to dependency: any UniversalComponent
    ) async throws {
        // Check for circular dependency
        if dependencyGraph.wouldCreateCycle(from: dependent.id, to: dependency.id) {
            throw HierarchyError.circularDependency([dependent.id, dependency.id])
        }
        
        // Add to component's dependencies
        dependent.dependencies.append(dependency.id)
        
        // Update graph
        dependencyGraph.addDependencyEdge(from: dependent.id, to: dependency.id)
        
        // Notify change
        notifyChange(.dependencyAdded(from: dependent.id, to: dependency.id))
    }
    
    /// Remove a dependency
    ///
    /// - Parameters:
    ///   - dependent: Component with dependency
    ///   - dependency: Dependency to remove
    public func removeDependency(
        from dependent: any UniversalComponent,
        to dependency: any UniversalComponent
    ) async throws {
        // Remove from component
        dependent.dependencies.removeAll { $0 == dependency.id }
        
        // Update graph
        dependencyGraph.removeDependencyEdge(from: dependent.id, to: dependency.id)
        
        // Notify change
        notifyChange(.dependencyRemoved(from: dependent.id, to: dependency.id))
    }
    
    /// Resolve all dependencies for a component
    ///
    /// - Parameter component: Component to resolve dependencies for
    /// - Returns: Resolved dependency components
    public func resolveDependencies(
        for component: any UniversalComponent
    ) async throws -> [any UniversalComponent] {
        var resolved: [any UniversalComponent] = []
        
        for dependencyId in component.dependencies {
            guard let dependency = componentRegistry[dependencyId] else {
                throw HierarchyError.missingDependency(dependencyId)
            }
            resolved.append(dependency)
        }
        
        return resolved
    }
    
    // MARK: - Tree Traversal
    
    /// Find all components of a specific type
    ///
    /// - Parameter type: Hierarchy level to search for
    /// - Returns: All components of the specified type
    public func findComponents(ofType type: HierarchyLevel) -> [any UniversalComponent] {
        return componentRegistry.values.filter { $0.hierarchyLevel == type }
    }
    
    /// Find a component by ID
    ///
    /// - Parameter id: Component ID
    /// - Returns: Component if found
    public func findComponent(by id: UUID) -> (any UniversalComponent)? {
        return componentRegistry[id]
    }
    
    /// Get all ancestors of a component
    ///
    /// - Parameter component: Component to get ancestors for
    /// - Returns: Array of ancestors from immediate parent to root
    public func getAncestors(of component: any UniversalComponent) -> [any UniversalComponent] {
        var ancestors: [any UniversalComponent] = []
        var current = component.parent
        
        while let parent = current {
            ancestors.append(parent)
            current = parent.parent
        }
        
        return ancestors
    }
    
    /// Get all descendants of a component
    ///
    /// - Parameter component: Component to get descendants for
    /// - Returns: All descendants in depth-first order
    public func getDescendants(of component: any UniversalComponent) -> [any UniversalComponent] {
        var descendants: [any UniversalComponent] = []
        
        func traverse(_ node: any UniversalComponent) {
            for child in node.children {
                descendants.append(child)
                traverse(child)
            }
        }
        
        traverse(component)
        return descendants
    }
    
    /// Get the root component of a hierarchy
    ///
    /// - Parameter component: Any component in the hierarchy
    /// - Returns: Root component
    public func getRoot(of component: any UniversalComponent) -> any UniversalComponent {
        var current = component
        while let parent = current.parent {
            current = parent
        }
        return current
    }
    
    // MARK: - Validation
    
    /// Validate the entire hierarchy
    ///
    /// - Parameter root: Root component to validate from
    /// - Returns: Validation result
    public func validateHierarchy(
        from root: any UniversalComponent
    ) async throws -> HierarchyValidation {
        var errors: [ValidationError] = []
        var warnings: [ValidationWarning] = []
        var visitedComponents: Set<UUID> = []
        
        // Recursive validation
        func validateNode(_ node: any UniversalComponent) {
            // Check for duplicate IDs
            if visitedComponents.contains(node.id) {
                errors.append(ValidationError(
                    component: node.id,
                    message: "Duplicate component ID detected",
                    severity: .critical
                ))
                return
            }
            visitedComponents.insert(node.id)
            
            // Validate hierarchy rules
            for rule in rules {
                if let error = rule.validate(node, in: self) {
                    errors.append(error)
                }
            }
            
            // Validate children
            for child in node.children {
                // Check parent-child consistency
                if child.parent?.id != node.id {
                    errors.append(ValidationError(
                        component: child.id,
                        message: "Inconsistent parent-child relationship",
                        severity: .high
                    ))
                }
                
                // Recursively validate
                validateNode(child)
            }
        }
        
        // Start validation
        validateNode(root)
        
        // Check for orphaned components
        let reachableComponents = visitedComponents
        let orphaned = componentRegistry.keys.filter { !reachableComponents.contains($0) }
        
        for orphanId in orphaned {
            warnings.append(ValidationWarning(
                component: orphanId,
                message: "Orphaned component not reachable from root"
            ))
        }
        
        // Update published errors
        validationErrors = errors
        
        return HierarchyValidation(
            isValid: errors.isEmpty,
            errors: errors,
            warnings: warnings,
            componentCount: visitedComponents.count,
            orphanedCount: orphaned.count
        )
    }
    
    // MARK: - Event Propagation
    
    /// Propagate an event up the hierarchy
    ///
    /// - Parameters:
    ///   - event: Event to propagate
    ///   - from: Starting component
    public func bubbleEvent(
        _ event: ComponentMessage,
        from component: any UniversalComponent
    ) async throws {
        var current = component.parent
        
        while let parent = current {
            try await parent.receiveMessage(event)
            
            // Check if event should continue bubbling
            if let stopBubbling = event.payload["stopPropagation"]?.value as? Bool,
               stopBubbling {
                break
            }
            
            current = parent.parent
        }
    }
    
    /// Broadcast an event down the hierarchy
    ///
    /// - Parameters:
    ///   - event: Event to broadcast
    ///   - from: Starting component
    public func broadcastEvent(
        _ event: ComponentMessage,
        from component: any UniversalComponent
    ) async throws {
        try await component.broadcast(event)
    }
    
    // MARK: - Private Methods
    
    /// Setup default hierarchy rules
    private func setupDefaultRules() {
        // Rule: Components can only contain lower-weight components
        rules.append(HierarchyWeightRule())
        
        // Rule: Maximum depth limit
        rules.append(MaxDepthRule(maxDepth: 10))
        
        // Rule: Maximum children per component
        rules.append(MaxChildrenRule(maxChildren: 100))
        
        // Rule: Dependency count limit
        rules.append(MaxDependenciesRule(maxDependencies: 20))
    }
    
    /// Register a component in the registry
    private func registerComponent(_ component: any UniversalComponent) {
        componentRegistry[component.id] = component
        
        // Recursively register children
        for child in component.children {
            registerComponent(child)
        }
    }
    
    /// Unregister a component from the registry
    private func unregisterComponent(_ component: any UniversalComponent) {
        componentRegistry.removeValue(forKey: component.id)
    }
    
    /// Validate adding a child to a parent
    private func validateAddition(child: any UniversalComponent, parent: any UniversalComponent) throws {
        // Check hierarchy weight rule
        if child.hierarchyLevel.weight >= parent.hierarchyLevel.weight {
            throw HierarchyError.invalidHierarchy(
                "Cannot add \(child.hierarchyLevel) as child of \(parent.hierarchyLevel)"
            )
        }
        
        // Check if child already has a parent
        if child.parent != nil {
            throw HierarchyError.alreadyHasParent
        }
        
        // Check maximum children
        if parent.children.count >= 100 {
            throw HierarchyError.maxChildrenExceeded
        }
    }
    
    /// Validate moving a component
    private func validateMove(component: any UniversalComponent, to newParent: any UniversalComponent) throws {
        // Prevent moving to self
        if component.id == newParent.id {
            throw HierarchyError.cannotMoveToSelf
        }
        
        // Prevent moving to descendant
        if getDescendants(of: component).contains(where: { $0.id == newParent.id }) {
            throw HierarchyError.cannotMoveToDescendant
        }
        
        // Validate hierarchy rules
        try validateAddition(child: component, parent: newParent)
    }
    
    /// Check for circular dependencies
    private func checkCircularDependency(child: any UniversalComponent, parent: any UniversalComponent) throws {
        // Check if adding this relationship would create a cycle
        if dependencyGraph.hasPath(from: child.id, to: parent.id) {
            throw HierarchyError.circularDependency([parent.id, child.id])
        }
    }
    
    /// Find components that depend on a given component
    private func findDependents(of component: any UniversalComponent) -> [any UniversalComponent] {
        let dependentIds = dependencyGraph.getDependents(of: component.id)
        return dependentIds.compactMap { componentRegistry[$0] }
    }
    
    /// Notify hierarchy change
    private func notifyChange(_ change: HierarchyChange) {
        lastChange = change
    }
}

// MARK: - Supporting Types

/// Hierarchy change notification
public enum HierarchyChange {
    case childAdded(parent: UUID, child: UUID)
    case componentRemoved(UUID)
    case componentMoved(component: UUID, from: UUID?, to: UUID)
    case childrenReordered(parent: UUID)
    case dependencyAdded(from: UUID, to: UUID)
    case dependencyRemoved(from: UUID, to: UUID)
}

/// Hierarchy validation result
public struct HierarchyValidation {
    public let isValid: Bool
    public let errors: [ValidationError]
    public let warnings: [ValidationWarning]
    public let componentCount: Int
    public let orphanedCount: Int
}

/// Validation error
public struct ValidationError {
    public let component: UUID
    public let message: String
    public let severity: Severity
    
    public enum Severity {
        case low, medium, high, critical
    }
}

/// Validation warning
public struct ValidationWarning {
    public let component: UUID
    public let message: String
}

/// Hierarchy errors
public enum HierarchyError: LocalizedError {
    case invalidHierarchy(String)
    case alreadyHasParent
    case maxChildrenExceeded
    case cannotRemove(String)
    case hasDependents([UUID])
    case cannotMoveToSelf
    case cannotMoveToDescendant
    case invalidReorder(String)
    case circularDependency([UUID])
    case missingDependency(UUID)
    
    public var errorDescription: String? {
        switch self {
        case .invalidHierarchy(let message):
            return "Invalid hierarchy: \(message)"
        case .alreadyHasParent:
            return "Component already has a parent"
        case .maxChildrenExceeded:
            return "Maximum children limit exceeded"
        case .cannotRemove(let reason):
            return "Cannot remove component: \(reason)"
        case .hasDependents(let ids):
            return "Component has dependents: \(ids.map { $0.uuidString }.joined(separator: ", "))"
        case .cannotMoveToSelf:
            return "Cannot move component to itself"
        case .cannotMoveToDescendant:
            return "Cannot move component to its own descendant"
        case .invalidReorder(let message):
            return "Invalid reorder: \(message)"
        case .circularDependency(let chain):
            return "Circular dependency: \(chain.map { $0.uuidString }.joined(separator: " -> "))"
        case .missingDependency(let id):
            return "Missing dependency: \(id)"
        }
    }
}

// MARK: - Hierarchy Rules

/// Protocol for hierarchy validation rules
@MainActor
protocol HierarchyRule {
    func validate(_ component: any UniversalComponent, in manager: HierarchyManager) -> ValidationError?
}

/// Rule: Components can only contain lower-weight components
struct HierarchyWeightRule: HierarchyRule {
    func validate(_ component: any UniversalComponent, in manager: HierarchyManager) -> ValidationError? {
        for child in component.children {
            if child.hierarchyLevel.weight >= component.hierarchyLevel.weight {
                return ValidationError(
                    component: component.id,
                    message: "Contains child with invalid hierarchy level",
                    severity: .high
                )
            }
        }
        return nil
    }
}

/// Rule: Maximum hierarchy depth
struct MaxDepthRule: HierarchyRule {
    let maxDepth: Int
    
    func validate(_ component: any UniversalComponent, in manager: HierarchyManager) -> ValidationError? {
        let depth = manager.getAncestors(of: component).count
        if depth > maxDepth {
            return ValidationError(
                component: component.id,
                message: "Exceeds maximum hierarchy depth of \(maxDepth)",
                severity: .medium
            )
        }
        return nil
    }
}

/// Rule: Maximum children per component
struct MaxChildrenRule: HierarchyRule {
    let maxChildren: Int
    
    func validate(_ component: any UniversalComponent, in manager: HierarchyManager) -> ValidationError? {
        if component.children.count > maxChildren {
            return ValidationError(
                component: component.id,
                message: "Exceeds maximum children limit of \(maxChildren)",
                severity: .medium
            )
        }
        return nil
    }
}

/// Rule: Maximum dependencies
struct MaxDependenciesRule: HierarchyRule {
    let maxDependencies: Int
    
    func validate(_ component: any UniversalComponent, in manager: HierarchyManager) -> ValidationError? {
        if component.dependencies.count > maxDependencies {
            return ValidationError(
                component: component.id,
                message: "Exceeds maximum dependencies limit of \(maxDependencies)",
                severity: .low
            )
        }
        return nil
    }
}

// MARK: - Dependency Graph

/// Internal dependency graph for cycle detection
@MainActor
private class DependencyGraph {
    private var adjacencyList: [UUID: Set<UUID>] = [:]
    private var dependencyList: [UUID: Set<UUID>] = [:]
    
    func addNode(_ component: any UniversalComponent) {
        adjacencyList[component.id] = Set()
        dependencyList[component.id] = Set()
    }
    
    func removeNode(_ id: UUID) {
        adjacencyList.removeValue(forKey: id)
        dependencyList.removeValue(forKey: id)
        
        // Remove from other nodes' lists
        for (key, _) in adjacencyList {
            adjacencyList[key]?.remove(id)
        }
        for (key, _) in dependencyList {
            dependencyList[key]?.remove(id)
        }
    }
    
    func addEdge(from: UUID, to: UUID) {
        adjacencyList[from]?.insert(to)
    }
    
    func removeEdge(from: UUID, to: UUID) {
        adjacencyList[from]?.remove(to)
    }
    
    func addDependencyEdge(from: UUID, to: UUID) {
        dependencyList[from]?.insert(to)
    }
    
    func removeDependencyEdge(from: UUID, to: UUID) {
        dependencyList[from]?.remove(to)
    }
    
    func hasPath(from: UUID, to: UUID) -> Bool {
        var visited: Set<UUID> = []
        var queue: [UUID] = [from]
        
        while !queue.isEmpty {
            let current = queue.removeFirst()
            if current == to { return true }
            
            if !visited.contains(current) {
                visited.insert(current)
                if let neighbors = adjacencyList[current] {
                    queue.append(contentsOf: neighbors)
                }
                if let dependencies = dependencyList[current] {
                    queue.append(contentsOf: dependencies)
                }
            }
        }
        
        return false
    }
    
    func wouldCreateCycle(from: UUID, to: UUID) -> Bool {
        return hasPath(from: to, to: from)
    }
    
    func getDependents(of id: UUID) -> Set<UUID> {
        var dependents: Set<UUID> = []
        
        for (component, dependencies) in dependencyList {
            if dependencies.contains(id) {
                dependents.insert(component)
            }
        }
        
        return dependents
    }
}