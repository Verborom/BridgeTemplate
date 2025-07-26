import Foundation

/// # VersionManager
///
/// Manages module versions, tracks version history, and handles version
/// compatibility checking across the Bridge Template ecosystem.
///
/// ## Overview
///
/// VersionManager provides comprehensive version management for the modular
/// system, enabling:
/// - **Version tracking**: Monitor all module versions and history
/// - **Compatibility checking**: Ensure modules work together
/// - **Version resolution**: Find compatible versions automatically
/// - **Update management**: Track and manage available updates
/// - **Rollback support**: Revert to previous versions safely
///
/// ## Topics
///
/// ### Version Information
/// - ``getModuleVersion(_:)``
/// - ``getVersionHistory(for:)``
/// - ``getLatestVersion(for:)``
/// - ``getCompatibleVersions(for:with:)``
///
/// ### Version Management
/// - ``registerVersion(_:for:)``
/// - ``bumpVersion(for:type:)``
/// - ``tagVersion(_:for:)``
///
/// ### Compatibility
/// - ``checkCompatibility(module:version:with:)``
/// - ``resolveVersionConflicts(_:)``
///
/// ### Version Manifest
/// - ``loadManifest()``
/// - ``saveManifest()``
/// - ``manifest``
///
/// ## Version History
/// - v1.0.0: Initial implementation
///
/// ## Usage
/// ```swift
/// let versionManager = VersionManager()
/// 
/// // Get current version
/// let version = versionManager.getModuleVersion("com.bridge.dashboard")
/// print(version) // "1.5.2"
/// 
/// // Check compatibility
/// let isCompatible = versionManager.checkCompatibility(
///     module: "com.bridge.projects",
///     version: "1.8.1",
///     with: loadedModules
/// )
/// 
/// // Bump version
/// let newVersion = try versionManager.bumpVersion(
///     for: "com.bridge.dashboard",
///     type: .patch
/// )
/// print(newVersion) // "1.5.3"
/// ```
public class VersionManager {
    
    /// Singleton instance
    public static let shared = VersionManager()
    
    /// Version manifest tracking all module versions
    private var manifest: VersionManifest
    
    /// Path to version manifest file
    private let manifestPath: URL
    
    /// Initialize the VersionManager
    private init() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.manifestPath = documentsPath.appendingPathComponent("BridgeTemplate/version-manifest.json")
        
        // Load existing manifest or create new one
        if let loaded = Self.loadManifest(from: manifestPath) {
            self.manifest = loaded
        } else {
            self.manifest = VersionManifest()
        }
    }
    
    /// Get the current version of a module
    ///
    /// - Parameter moduleId: Module identifier
    /// - Returns: Current version string or nil if not found
    public func getModuleVersion(_ moduleId: String) -> String? {
        manifest.modules[moduleId]?.currentVersion
    }
    
    /// Get version history for a module
    ///
    /// - Parameter moduleId: Module identifier
    /// - Returns: Array of version records sorted by date
    public func getVersionHistory(for moduleId: String) -> [VersionRecord] {
        manifest.modules[moduleId]?.history ?? []
    }
    
    /// Get the latest available version for a module
    ///
    /// - Parameter moduleId: Module identifier
    /// - Returns: Latest version string or nil if not found
    public func getLatestVersion(for moduleId: String) -> String? {
        guard let moduleInfo = manifest.modules[moduleId] else { return nil }
        return moduleInfo.availableVersions.sorted { version1, version2 in
            ModuleVersion(from: version1) > ModuleVersion(from: version2)
        }.first
    }
    
    /// Get compatible versions for a module
    ///
    /// Finds all versions of a module that are compatible with
    /// the specified set of loaded modules.
    ///
    /// - Parameters:
    ///   - moduleId: Module identifier
    ///   - loadedModules: Currently loaded modules to check against
    /// - Returns: Array of compatible version strings
    public func getCompatibleVersions(
        for moduleId: String,
        with loadedModules: [String: ModuleVersion]
    ) -> [String] {
        guard let moduleInfo = manifest.modules[moduleId] else { return [] }
        
        return moduleInfo.availableVersions.filter { version in
            checkCompatibility(
                module: moduleId,
                version: version,
                with: loadedModules
            )
        }
    }
    
    /// Register a new version for a module
    ///
    /// Records a new version in the manifest and updates history.
    ///
    /// - Parameters:
    ///   - version: Version string to register
    ///   - moduleId: Module identifier
    /// - Throws: VersionError if registration fails
    public func registerVersion(_ version: String, for moduleId: String) throws {
        var moduleInfo = manifest.modules[moduleId] ?? ModuleVersionInfo(
            identifier: moduleId,
            currentVersion: version,
            availableVersions: [],
            history: []
        )
        
        // Add to available versions if not present
        if !moduleInfo.availableVersions.contains(version) {
            moduleInfo.availableVersions.append(version)
        }
        
        // Update current version
        moduleInfo.currentVersion = version
        
        // Add to history
        let record = VersionRecord(
            version: version,
            timestamp: Date(),
            changelog: nil,
            commitHash: nil
        )
        moduleInfo.history.append(record)
        
        // Update manifest
        manifest.modules[moduleId] = moduleInfo
        try saveManifest()
    }
    
    /// Bump version for a module
    ///
    /// Increments the version number according to semantic versioning rules.
    ///
    /// - Parameters:
    ///   - moduleId: Module identifier
    ///   - type: Type of version bump (major, minor, patch)
    /// - Returns: New version string
    /// - Throws: VersionError if bump fails
    public func bumpVersion(for moduleId: String, type: VersionBumpType) throws -> String {
        guard let currentVersionString = getModuleVersion(moduleId) else {
            throw VersionError.moduleNotFound(moduleId)
        }
        
        let currentVersion = ModuleVersion(from: currentVersionString)
        let newVersion: ModuleVersion
        
        switch type {
        case .major:
            newVersion = ModuleVersion(
                major: currentVersion.major + 1,
                minor: 0,
                patch: 0
            )
        case .minor:
            newVersion = ModuleVersion(
                major: currentVersion.major,
                minor: currentVersion.minor + 1,
                patch: 0
            )
        case .patch:
            newVersion = ModuleVersion(
                major: currentVersion.major,
                minor: currentVersion.minor,
                patch: currentVersion.patch + 1
            )
        }
        
        try registerVersion(newVersion.description, for: moduleId)
        return newVersion.description
    }
    
    /// Tag a version with additional metadata
    ///
    /// Adds commit hash, changelog, or other metadata to a version record.
    ///
    /// - Parameters:
    ///   - version: Version to tag
    ///   - moduleId: Module identifier
    ///   - commitHash: Git commit hash (optional)
    ///   - changelog: Version changelog (optional)
    public func tagVersion(
        _ version: String,
        for moduleId: String,
        commitHash: String? = nil,
        changelog: String? = nil
    ) {
        guard var moduleInfo = manifest.modules[moduleId],
              let index = moduleInfo.history.firstIndex(where: { $0.version == version }) else {
            return
        }
        
        moduleInfo.history[index].commitHash = commitHash
        moduleInfo.history[index].changelog = changelog
        
        manifest.modules[moduleId] = moduleInfo
        try? saveManifest()
    }
    
    /// Check if a module version is compatible with loaded modules
    ///
    /// Verifies that the specified version of a module is compatible
    /// with all currently loaded modules.
    ///
    /// - Parameters:
    ///   - module: Module identifier to check
    ///   - version: Version to check
    ///   - loadedModules: Currently loaded modules
    /// - Returns: true if compatible, false otherwise
    public func checkCompatibility(
        module: String,
        version: String,
        with loadedModules: [String: ModuleVersion]
    ) -> Bool {
        // Get dependency requirements for this version
        guard let requirements = manifest.compatibility[module]?[version] else {
            // No requirements specified - assume compatible
            return true
        }
        
        // Check each requirement
        for (dependencyId, requiredVersion) in requirements {
            guard let loadedVersion = loadedModules[dependencyId] else {
                // Dependency not loaded - incompatible
                return false
            }
            
            // Check version compatibility
            if !isVersionCompatible(loaded: loadedVersion, required: requiredVersion) {
                return false
            }
        }
        
        return true
    }
    
    /// Resolve version conflicts between modules
    ///
    /// Attempts to find a set of module versions that are all
    /// mutually compatible.
    ///
    /// - Parameter modules: Dictionary of module IDs to desired versions
    /// - Returns: Resolved versions or nil if no solution exists
    public func resolveVersionConflicts(
        _ modules: [String: String]
    ) -> [String: String]? {
        // This is a simplified version - in production this would
        // use a proper constraint solver
        
        var resolved: [String: String] = [:]
        
        // Try to satisfy each module's requirements
        for (moduleId, desiredVersion) in modules {
            let compatibleVersions = getCompatibleVersions(
                for: moduleId,
                with: resolved.mapValues { ModuleVersion(from: $0) }
            )
            
            if compatibleVersions.contains(desiredVersion) {
                resolved[moduleId] = desiredVersion
            } else if let alternative = compatibleVersions.first {
                resolved[moduleId] = alternative
            } else {
                // No compatible version found
                return nil
            }
        }
        
        return resolved
    }
    
    // MARK: - Private Methods
    
    /// Load manifest from disk
    private static func loadManifest(from url: URL) -> VersionManifest? {
        guard let data = try? Data(contentsOf: url),
              let manifest = try? JSONDecoder().decode(VersionManifest.self, from: data) else {
            return nil
        }
        return manifest
    }
    
    /// Save manifest to disk
    private func saveManifest() throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(manifest)
        
        // Create directory if needed
        try FileManager.default.createDirectory(
            at: manifestPath.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        
        try data.write(to: manifestPath)
    }
    
    /// Check if a loaded version satisfies a requirement
    private func isVersionCompatible(loaded: ModuleVersion, required: String) -> Bool {
        // Parse requirement (supports ^, ~, =, >, >=, <, <=)
        if required.hasPrefix("^") {
            // Compatible with minor/patch updates
            let requiredVersion = ModuleVersion(from: String(required.dropFirst()))
            return loaded.major == requiredVersion.major && loaded >= requiredVersion
        } else if required.hasPrefix("~") {
            // Compatible with patch updates only
            let requiredVersion = ModuleVersion(from: String(required.dropFirst()))
            return loaded.major == requiredVersion.major &&
                   loaded.minor == requiredVersion.minor &&
                   loaded >= requiredVersion
        } else if required.hasPrefix(">=") {
            let requiredVersion = ModuleVersion(from: String(required.dropFirst(2)))
            return loaded >= requiredVersion
        } else if required.hasPrefix(">") {
            let requiredVersion = ModuleVersion(from: String(required.dropFirst()))
            return loaded > requiredVersion
        } else if required.hasPrefix("<=") {
            let requiredVersion = ModuleVersion(from: String(required.dropFirst(2)))
            return loaded <= requiredVersion
        } else if required.hasPrefix("<") {
            let requiredVersion = ModuleVersion(from: String(required.dropFirst()))
            return loaded < requiredVersion
        } else if required.hasPrefix("=") {
            let requiredVersion = ModuleVersion(from: String(required.dropFirst()))
            return loaded == requiredVersion
        } else {
            // Exact match required
            return loaded.description == required
        }
    }
}

/// # VersionManifest
///
/// The complete version manifest for all modules in the system.
///
/// ## Topics
///
/// ### Properties
/// - ``appVersion``
/// - ``modules``
/// - ``compatibility``
/// - ``lastUpdated``
public struct VersionManifest: Codable {
    
    /// Current app version
    public var appVersion: String = "2.0.0"
    
    /// Module version information
    public var modules: [String: ModuleVersionInfo] = [:]
    
    /// Compatibility matrix
    ///
    /// Maps module ID -> version -> dependencies
    public var compatibility: [String: [String: [String: String]]] = [:]
    
    /// Last update timestamp
    public var lastUpdated: Date = Date()
}

/// # ModuleVersionInfo
///
/// Version information for a single module.
public struct ModuleVersionInfo: Codable {
    
    /// Module identifier
    public let identifier: String
    
    /// Current version
    public var currentVersion: String
    
    /// All available versions
    public var availableVersions: [String]
    
    /// Version history
    public var history: [VersionRecord]
}

/// # VersionRecord
///
/// Historical record of a module version.
public struct VersionRecord: Codable {
    
    /// Version string
    public let version: String
    
    /// Release timestamp
    public let timestamp: Date
    
    /// Version changelog
    public var changelog: String?
    
    /// Git commit hash
    public var commitHash: String?
}

/// # VersionBumpType
///
/// Type of version increment.
public enum VersionBumpType {
    /// Major version bump (breaking changes)
    case major
    
    /// Minor version bump (new features)
    case minor
    
    /// Patch version bump (bug fixes)
    case patch
}

/// # VersionError
///
/// Errors that can occur during version operations.
public enum VersionError: LocalizedError {
    /// Module not found in manifest
    case moduleNotFound(String)
    
    /// Invalid version format
    case invalidVersion(String)
    
    /// Version conflict detected
    case versionConflict(String)
    
    public var errorDescription: String? {
        switch self {
        case .moduleNotFound(let id):
            return "Module '\(id)' not found in version manifest"
        case .invalidVersion(let version):
            return "Invalid version format: '\(version)'"
        case .versionConflict(let details):
            return "Version conflict: \(details)"
        }
    }
}

// MARK: - ModuleVersion Extension

extension ModuleVersion {
    /// Initialize from version string
    init(from string: String) {
        let components = string.split(separator: ".")
        self.init(
            major: Int(components[0]) ?? 0,
            minor: components.count > 1 ? Int(components[1]) ?? 0 : 0,
            patch: components.count > 2 ? Int(components[2]) ?? 0 : 0
        )
    }
}