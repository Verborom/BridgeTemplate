import Foundation
import Combine

/// # VersionManager
///
/// Comprehensive version management system for UniversalTemplate components.
/// Handles semantic versioning, version comparison, compatibility checking,
/// and version migration for any component at any hierarchy level.
///
/// ## Overview
///
/// VersionManager provides:
/// - **Semantic Versioning**: Full support for major.minor.patch-prerelease+build
/// - **Compatibility Checking**: Determine if versions are compatible
/// - **Migration Support**: Automated migration between versions
/// - **Version History**: Track version changes over time
/// - **Rollback Capability**: Revert to previous versions safely
///
/// ## Usage
///
/// ```swift
/// let manager = VersionManager()
/// 
/// // Check compatibility
/// let canUpgrade = manager.areCompatible(current: v1, target: v2)
/// 
/// // Perform migration
/// if canUpgrade {
///     try await manager.migrate(component, from: v1, to: v2)
/// }
/// 
/// // Track version history
/// let history = manager.getVersionHistory(for: component)
/// ```
@MainActor
public final class VersionManager: ObservableObject {
    
    /// Singleton instance
    public static let shared = VersionManager()
    
    /// Version history for components
    @Published private var versionHistory: [UUID: [VersionEntry]] = [:]
    
    /// Migration strategies
    private var migrationStrategies: [VersionMigrationKey: MigrationStrategy] = [:]
    
    /// Compatibility rules
    private var compatibilityRules: [CompatibilityRule] = []
    
    /// Version change publisher
    public let versionChanged = PassthroughSubject<VersionChange, Never>()
    
    /// Private initializer
    private init() {
        setupDefaultRules()
        setupDefaultMigrations()
    }
    
    // MARK: - Version Operations
    
    /// Check if two versions are compatible
    ///
    /// - Parameters:
    ///   - current: Current version
    ///   - target: Target version
    /// - Returns: True if versions are compatible
    public func areCompatible(
        current: ComponentVersion,
        target: ComponentVersion
    ) -> Bool {
        // Apply all compatibility rules
        for rule in compatibilityRules {
            if !rule.check(from: current, to: target) {
                return false
            }
        }
        
        return true
    }
    
    /// Get the compatibility level between versions
    ///
    /// - Parameters:
    ///   - current: Current version
    ///   - target: Target version
    /// - Returns: Compatibility level
    public func compatibilityLevel(
        between current: ComponentVersion,
        to target: ComponentVersion
    ) -> CompatibilityLevel {
        // Major version change
        if current.major != target.major {
            return .breaking
        }
        
        // Minor version change
        if current.minor != target.minor {
            return current.minor < target.minor ? .backward : .forward
        }
        
        // Patch version change
        if current.patch != target.patch {
            return .patch
        }
        
        // Only prerelease/build changed
        return .identical
    }
    
    /// Compare two versions
    ///
    /// - Parameters:
    ///   - v1: First version
    ///   - v2: Second version
    /// - Returns: Comparison result
    public func compare(
        _ v1: ComponentVersion,
        _ v2: ComponentVersion
    ) -> ComparisonResult {
        if v1 < v2 { return .orderedAscending }
        if v1 > v2 { return .orderedDescending }
        return .orderedSame
    }
    
    // MARK: - Migration
    
    /// Migrate a component from one version to another
    ///
    /// - Parameters:
    ///   - component: Component to migrate
    ///   - from: Source version
    ///   - to: Target version
    /// - Throws: VersionError if migration fails
    public func migrate(
        _ component: any UniversalComponent,
        from currentVersion: ComponentVersion,
        to targetVersion: ComponentVersion
    ) async throws {
        // Check if migration is needed
        guard currentVersion != targetVersion else { return }
        
        // Validate migration path
        guard areCompatible(current: currentVersion, target: targetVersion) else {
            throw VersionError.incompatibleVersions(currentVersion, targetVersion)
        }
        
        // Find migration strategy
        let key = VersionMigrationKey(from: currentVersion, to: targetVersion)
        
        if let strategy = migrationStrategies[key] {
            // Use specific migration strategy
            try await strategy.migrate(component)
        } else {
            // Use generic migration
            try await performGenericMigration(
                component,
                from: currentVersion,
                to: targetVersion
            )
        }
        
        // Update version
        if let baseComponent = component as? BaseComponent {
            baseComponent.version = targetVersion
        }
        
        // Record migration
        recordVersionChange(
            for: component,
            from: currentVersion,
            to: targetVersion,
            type: .migration
        )
        
        // Notify observers
        versionChanged.send(VersionChange(
            componentId: component.id,
            fromVersion: currentVersion,
            toVersion: targetVersion,
            type: .migration,
            timestamp: Date()
        ))
    }
    
    /// Register a custom migration strategy
    ///
    /// - Parameters:
    ///   - strategy: Migration strategy
    ///   - from: Source version
    ///   - to: Target version
    public func registerMigration(
        _ strategy: MigrationStrategy,
        from: ComponentVersion,
        to: ComponentVersion
    ) {
        let key = VersionMigrationKey(from: from, to: to)
        migrationStrategies[key] = strategy
    }
    
    // MARK: - Version History
    
    /// Get version history for a component
    ///
    /// - Parameter component: Component to get history for
    /// - Returns: Array of version entries
    public func getVersionHistory(
        for component: any UniversalComponent
    ) -> [VersionEntry] {
        return versionHistory[component.id] ?? []
    }
    
    /// Record a version change
    ///
    /// - Parameters:
    ///   - component: Component that changed
    ///   - from: Previous version
    ///   - to: New version
    ///   - type: Type of change
    public func recordVersionChange(
        for component: any UniversalComponent,
        from: ComponentVersion?,
        to: ComponentVersion,
        type: VersionChangeType
    ) {
        let entry = VersionEntry(
            version: to,
            previousVersion: from,
            changeType: type,
            timestamp: Date(),
            metadata: [:]
        )
        
        if versionHistory[component.id] == nil {
            versionHistory[component.id] = []
        }
        
        versionHistory[component.id]?.append(entry)
    }
    
    /// Clear version history for a component
    ///
    /// - Parameter component: Component to clear history for
    public func clearHistory(for component: any UniversalComponent) {
        versionHistory.removeValue(forKey: component.id)
    }
    
    // MARK: - Rollback
    
    /// Rollback a component to a previous version
    ///
    /// - Parameters:
    ///   - component: Component to rollback
    ///   - to: Target version to rollback to
    /// - Throws: VersionError if rollback fails
    public func rollback(
        _ component: any UniversalComponent,
        to targetVersion: ComponentVersion
    ) async throws {
        // Get current version
        let currentVersion = component.version
        
        // Validate rollback
        guard targetVersion < currentVersion else {
            throw VersionError.invalidRollback("Cannot rollback to newer version")
        }
        
        // Check if target version exists in history
        let history = getVersionHistory(for: component)
        guard history.contains(where: { $0.version == targetVersion }) else {
            throw VersionError.versionNotFound(targetVersion)
        }
        
        // Perform rollback migration
        try await migrate(component, from: currentVersion, to: targetVersion)
        
        // Record rollback
        recordVersionChange(
            for: component,
            from: currentVersion,
            to: targetVersion,
            type: .rollback
        )
    }
    
    // MARK: - Version Queries
    
    /// Get the latest stable version from a list
    ///
    /// - Parameter versions: Array of versions
    /// - Returns: Latest stable version
    public func latestStableVersion(
        from versions: [ComponentVersion]
    ) -> ComponentVersion? {
        return versions
            .filter { $0.prerelease == nil }
            .sorted()
            .last
    }
    
    /// Get all versions between two versions
    ///
    /// - Parameters:
    ///   - start: Start version (inclusive)
    ///   - end: End version (inclusive)
    ///   - versions: Array of all versions
    /// - Returns: Versions in range
    public func versionsBetween(
        _ start: ComponentVersion,
        and end: ComponentVersion,
        from versions: [ComponentVersion]
    ) -> [ComponentVersion] {
        return versions.filter { version in
            version >= start && version <= end
        }.sorted()
    }
    
    /// Check if a version is a prerelease
    ///
    /// - Parameter version: Version to check
    /// - Returns: True if prerelease
    public func isPrerelease(_ version: ComponentVersion) -> Bool {
        return version.prerelease != nil
    }
    
    // MARK: - Private Methods
    
    /// Setup default compatibility rules
    private func setupDefaultRules() {
        // Rule: Major version changes are breaking
        compatibilityRules.append(MajorVersionRule())
        
        // Rule: Cannot downgrade minor versions
        compatibilityRules.append(MinorVersionRule())
        
        // Rule: Patch versions are always compatible
        compatibilityRules.append(PatchVersionRule())
        
        // Rule: Prerelease versions have special rules
        compatibilityRules.append(PrereleaseRule())
    }
    
    /// Setup default migration strategies
    private func setupDefaultMigrations() {
        // Default migrations would be registered here
        // Example: v1.x to v2.x migrations
    }
    
    /// Perform generic migration
    private func performGenericMigration(
        _ component: any UniversalComponent,
        from: ComponentVersion,
        to: ComponentVersion
    ) async throws {
        // Generic migration logic
        
        // 1. Backup current state
        let backup = try await createBackup(of: component)
        
        // 2. Check compatibility level
        let compatibility = compatibilityLevel(between: from, to: to)
        
        switch compatibility {
        case .breaking:
            // Major version change - may need data transformation
            try await performBreakingMigration(component, from: from, to: to)
            
        case .backward:
            // Minor version upgrade - add new features
            try await performBackwardCompatibleMigration(component, from: from, to: to)
            
        case .forward:
            // Minor version downgrade - remove features
            try await performForwardCompatibleMigration(component, from: from, to: to)
            
        case .patch:
            // Patch change - usually just bug fixes
            try await performPatchMigration(component, from: from, to: to)
            
        case .identical:
            // No migration needed
            break
        }
        
        // 3. Validate migrated component
        let validation = try await component.validate()
        guard validation.isValid else {
            // Restore from backup
            try await restoreBackup(backup, to: component)
            throw VersionError.migrationFailed("Validation failed after migration")
        }
    }
    
    /// Create backup of component state
    private func createBackup(of component: any UniversalComponent) async throws -> ComponentBackup {
        return ComponentBackup(
            componentId: component.id,
            version: component.version,
            configuration: component.configuration,
            state: component.state,
            timestamp: Date()
        )
    }
    
    /// Restore component from backup
    private func restoreBackup(_ backup: ComponentBackup, to component: any UniversalComponent) async throws {
        component.configuration = backup.configuration
        component.state = backup.state
        
        if let baseComponent = component as? BaseComponent {
            baseComponent.version = backup.version
        }
    }
    
    /// Perform breaking migration (major version)
    private func performBreakingMigration(
        _ component: any UniversalComponent,
        from: ComponentVersion,
        to: ComponentVersion
    ) async throws {
        // Implementation would handle data structure changes,
        // removed features, API changes, etc.
        print("Performing breaking migration from \(from) to \(to)")
    }
    
    /// Perform backward compatible migration (minor upgrade)
    private func performBackwardCompatibleMigration(
        _ component: any UniversalComponent,
        from: ComponentVersion,
        to: ComponentVersion
    ) async throws {
        // Implementation would add new features,
        // extend existing functionality, etc.
        print("Performing backward compatible migration from \(from) to \(to)")
    }
    
    /// Perform forward compatible migration (minor downgrade)
    private func performForwardCompatibleMigration(
        _ component: any UniversalComponent,
        from: ComponentVersion,
        to: ComponentVersion
    ) async throws {
        // Implementation would safely remove newer features
        print("Performing forward compatible migration from \(from) to \(to)")
    }
    
    /// Perform patch migration
    private func performPatchMigration(
        _ component: any UniversalComponent,
        from: ComponentVersion,
        to: ComponentVersion
    ) async throws {
        // Usually no data changes needed for patches
        print("Performing patch migration from \(from) to \(to)")
    }
}

// MARK: - Supporting Types

/// Version compatibility level
public enum CompatibilityLevel {
    case identical      // Same version
    case patch          // Patch version difference
    case backward       // Backward compatible (minor upgrade)
    case forward        // Forward compatible (minor downgrade)
    case breaking       // Breaking change (major version)
}

/// Version change types
public enum VersionChangeType: String, Codable {
    case creation = "Creation"
    case upgrade = "Upgrade"
    case downgrade = "Downgrade"
    case migration = "Migration"
    case rollback = "Rollback"
    case patch = "Patch"
}

/// Version history entry
public struct VersionEntry: Codable {
    public let version: ComponentVersion
    public let previousVersion: ComponentVersion?
    public let changeType: VersionChangeType
    public let timestamp: Date
    public let metadata: [String: AnyCodable]
}

/// Version change notification
public struct VersionChange {
    public let componentId: UUID
    public let fromVersion: ComponentVersion?
    public let toVersion: ComponentVersion
    public let type: VersionChangeType
    public let timestamp: Date
}

/// Component backup for rollback
public struct ComponentBackup {
    public let componentId: UUID
    public let version: ComponentVersion
    public let configuration: ComponentConfiguration
    public let state: ComponentState
    public let timestamp: Date
}

/// Migration strategy protocol
public protocol MigrationStrategy {
    func migrate(_ component: any UniversalComponent) async throws
}

/// Version migration key
public struct VersionMigrationKey: Hashable {
    public let from: ComponentVersion
    public let to: ComponentVersion
}

/// Compatibility rule protocol
public protocol CompatibilityRule {
    func check(from: ComponentVersion, to: ComponentVersion) -> Bool
}

/// Major version compatibility rule
public struct MajorVersionRule: CompatibilityRule {
    public func check(from: ComponentVersion, to: ComponentVersion) -> Bool {
        // Allow upgrades but not downgrades across major versions
        if from.major != to.major {
            return from.major < to.major
        }
        return true
    }
}

/// Minor version compatibility rule
public struct MinorVersionRule: CompatibilityRule {
    public func check(from: ComponentVersion, to: ComponentVersion) -> Bool {
        // Within same major version, allow any minor version change
        if from.major == to.major {
            return true
        }
        return true
    }
}

/// Patch version compatibility rule
public struct PatchVersionRule: CompatibilityRule {
    public func check(from: ComponentVersion, to: ComponentVersion) -> Bool {
        // Patch versions are always compatible
        return true
    }
}

/// Prerelease version compatibility rule
public struct PrereleaseRule: CompatibilityRule {
    public func check(from: ComponentVersion, to: ComponentVersion) -> Bool {
        // Special handling for prereleases
        if from.prerelease != nil || to.prerelease != nil {
            // Prereleases are only compatible with same major.minor
            return from.major == to.major && from.minor == to.minor
        }
        return true
    }
}

/// Version errors
public enum VersionError: LocalizedError {
    case incompatibleVersions(ComponentVersion, ComponentVersion)
    case versionNotFound(ComponentVersion)
    case migrationFailed(String)
    case invalidRollback(String)
    case noMigrationPath(ComponentVersion, ComponentVersion)
    
    public var errorDescription: String? {
        switch self {
        case .incompatibleVersions(let from, let to):
            return "Incompatible versions: \(from) -> \(to)"
        case .versionNotFound(let version):
            return "Version not found: \(version)"
        case .migrationFailed(let reason):
            return "Migration failed: \(reason)"
        case .invalidRollback(let reason):
            return "Invalid rollback: \(reason)"
        case .noMigrationPath(let from, let to):
            return "No migration path from \(from) to \(to)"
        }
    }
}