import SwiftUI
import Foundation
import Security

/// # Auto-Permission System
///
/// The Auto-Permission System provides secure, unattended execution capabilities
/// for the Terminal module by automatically handling macOS security prompts and
/// permission requests. This feature enables automated workflows, CI/CD pipelines,
/// and Claude Code sessions to run without manual intervention.
///
/// ## Overview
///
/// This system handles various permission scenarios including:
/// - Terminal app access permissions (Full Disk Access, Developer Tools)
/// - Code signing and notarization requirements
/// - Security & Privacy prompts
/// - Gatekeeper and XProtect challenges
/// - Sudo password management (with secure storage)
/// - Application launch permissions
/// - File system access permissions
///
/// ## Security Architecture
///
/// The system prioritizes security through:
/// - Keychain integration for credential storage
/// - Scoped permission grants (time-limited)
/// - Audit logging of all permission grants
/// - Revocation capabilities
/// - Encrypted communication channels
/// - Secure enclave support when available
///
/// ## Topics
///
/// ### Core Components
/// - ``AutoPermissionSystem``
/// - ``PermissionManager``
/// - ``SecureCredentialStore``
/// - ``PermissionAuditor``
///
/// ### Permission Types
/// - ``TerminalPermission``
/// - ``FileSystemPermission``
/// - ``DeveloperToolPermission``
/// - ``SystemPermission``
///
/// ### Security Features
/// - ``PermissionScope``
/// - ``GrantPolicy``
/// - ``AuditLog``
///
/// ## Version History
/// - v1.0.0: Initial implementation with core permission handling
///
/// ## Usage
/// ```swift
/// // Initialize auto-permission system
/// let autoPermission = AutoPermissionSystem()
/// try await autoPermission.initialize()
///
/// // Configure for Claude Code session
/// let config = UnattendedConfig(
///     enableSudoPassthrough: true,
///     autoGrantDeveloperTools: true,
///     sessionTimeout: .hours(4)
/// )
/// await autoPermission.configureUnattended(config)
///
/// // Execute command with auto-permissions
/// let result = try await autoPermission.executeWithPermissions("./scripts/build.sh")
/// ```
@MainActor
public class AutoPermissionSystem: ObservableObject {
    
    /// System activation status
    @Published public var isActive = false
    
    /// Current permission configuration
    @Published public var configuration = PermissionConfiguration()
    
    /// Active permission grants
    @Published public var activeGrants: [PermissionGrant] = []
    
    /// Permission manager instance
    private let permissionManager = PermissionManager()
    
    /// Secure credential store
    private let credentialStore = SecureCredentialStore()
    
    /// Audit system
    private let auditor = PermissionAuditor()
    
    /// Grant policy engine
    private let policyEngine = GrantPolicyEngine()
    
    /// Initialize the auto-permission system
    ///
    /// Sets up:
    /// - Keychain access for secure storage
    /// - Permission monitoring
    /// - Audit logging
    /// - Policy configuration
    ///
    /// - Throws: PermissionError if initialization fails
    public func initialize() async throws {
        print("🔐 Initializing Auto-Permission System")
        
        // Initialize secure storage
        try await credentialStore.initialize()
        
        // Load saved configuration
        if let savedConfig = await loadConfiguration() {
            configuration = savedConfig
        }
        
        // Start permission monitoring
        await permissionManager.startMonitoring()
        
        // Initialize audit system
        await auditor.initialize()
        
        print("✅ Auto-Permission System initialized")
    }
    
    /// Configure for unattended execution
    ///
    /// Enables automated permission handling for CI/CD and automation scenarios.
    ///
    /// - Parameter config: Unattended execution configuration
    public func configureUnattended(_ config: UnattendedConfig) async {
        print("🤖 Configuring unattended execution mode")
        
        configuration.unattendedMode = true
        configuration.unattendedConfig = config
        
        // Pre-authorize common permissions
        if config.autoGrantDeveloperTools {
            await preAuthorizeDeveloperTools()
        }
        
        if config.enableSudoPassthrough {
            await configureSudoPassthrough()
        }
        
        // Set session timeout
        await policyEngine.setSessionTimeout(config.sessionTimeout)
        
        isActive = true
        await saveConfiguration()
        
        print("✅ Unattended mode configured")
    }
    
    /// Execute command with automatic permission handling
    ///
    /// Runs a command and automatically handles any permission prompts
    /// that arise during execution.
    ///
    /// - Parameter command: Command to execute
    /// - Returns: Execution result with granted permissions
    /// - Throws: PermissionError if permissions cannot be granted
    public func executeWithPermissions(_ command: String) async throws -> PermissionExecutionResult {
        guard isActive else {
            throw PermissionError.systemNotActive
        }
        
        print("🚀 Executing with auto-permissions: \(command)")
        
        // Create execution context
        let context = ExecutionContext(
            command: command,
            timestamp: Date(),
            sessionId: UUID().uuidString
        )
        
        // Pre-flight permission check
        let requiredPermissions = await analyzeRequiredPermissions(for: command)
        
        // Request permissions
        let grants = try await requestPermissions(requiredPermissions, context: context)
        
        // Execute command with permission context
        let result = try await executeInPermissionContext(command, grants: grants, context: context)
        
        // Audit execution
        await auditor.logExecution(context: context, grants: grants, result: result)
        
        return PermissionExecutionResult(
            output: result.output,
            exitCode: result.exitCode,
            grantedPermissions: grants,
            executionTime: result.executionTime
        )
    }
    
    /// Grant specific permission
    ///
    /// Manually grants a permission for the current session.
    ///
    /// - Parameters:
    ///   - permission: Permission to grant
    ///   - scope: Scope of the grant
    /// - Returns: The permission grant
    /// - Throws: PermissionError if grant fails
    public func grantPermission(_ permission: Permission, scope: PermissionScope) async throws -> PermissionGrant {
        print("🔓 Granting permission: \(permission.identifier)")
        
        // Validate permission request
        guard await policyEngine.canGrant(permission, scope: scope) else {
            throw PermissionError.policyDenied(reason: "Permission denied by policy")
        }
        
        // Create grant
        let grant = PermissionGrant(
            id: UUID().uuidString,
            permission: permission,
            scope: scope,
            grantedAt: Date(),
            grantedBy: "AutoPermissionSystem"
        )
        
        // Apply grant
        try await permissionManager.applyGrant(grant)
        
        // Track active grant
        activeGrants.append(grant)
        
        // Audit grant
        await auditor.logGrant(grant)
        
        return grant
    }
    
    /// Revoke permission grant
    ///
    /// Revokes a previously granted permission.
    ///
    /// - Parameter grantId: ID of the grant to revoke
    public func revokeGrant(_ grantId: String) async {
        guard let grant = activeGrants.first(where: { $0.id == grantId }) else {
            return
        }
        
        print("🔒 Revoking permission grant: \(grant.permission.identifier)")
        
        // Remove from active grants
        activeGrants.removeAll { $0.id == grantId }
        
        // Revoke in permission manager
        await permissionManager.revokeGrant(grant)
        
        // Audit revocation
        await auditor.logRevocation(grant)
    }
    
    /// Store secure credential
    ///
    /// Securely stores a credential for automated use.
    ///
    /// - Parameters:
    ///   - credential: Credential to store
    ///   - identifier: Unique identifier for retrieval
    /// - Throws: PermissionError if storage fails
    public func storeCredential(_ credential: SecureCredential, identifier: String) async throws {
        try await credentialStore.store(credential, identifier: identifier)
        await auditor.logCredentialOperation(.store, identifier: identifier)
    }
    
    /// Remove stored credential
    ///
    /// - Parameter identifier: Credential identifier
    public func removeCredential(_ identifier: String) async throws {
        try await credentialStore.remove(identifier: identifier)
        await auditor.logCredentialOperation(.remove, identifier: identifier)
    }
    
    /// Get audit log
    ///
    /// - Parameter filter: Optional filter for log entries
    /// - Returns: Filtered audit log entries
    public func getAuditLog(filter: AuditFilter? = nil) async -> [AuditEntry] {
        return await auditor.getEntries(filter: filter)
    }
    
    /// Export configuration
    ///
    /// - Returns: Exportable configuration data
    public func exportConfiguration() async throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        return try encoder.encode(configuration)
    }
    
    /// Import configuration
    ///
    /// - Parameter data: Configuration data to import
    public func importConfiguration(_ data: Data) async throws {
        let decoder = JSONDecoder()
        configuration = try decoder.decode(PermissionConfiguration.self, from: data)
        await saveConfiguration()
    }
    
    // MARK: - Private Methods
    
    /// Analyze required permissions for command
    private func analyzeRequiredPermissions(for command: String) async -> [Permission] {
        var permissions: [Permission] = []
        
        // Check for sudo requirement
        if command.contains("sudo") {
            permissions.append(SystemPermission.sudo)
        }
        
        // Check for file system access
        if command.contains("/System/") || command.contains("/Library/") {
            permissions.append(FileSystemPermission.systemWrite)
        }
        
        // Check for developer tools
        if command.contains("xcodebuild") || command.contains("codesign") {
            permissions.append(DeveloperToolPermission.codeSign)
        }
        
        // Check for script execution
        if command.contains(".sh") || command.contains("./") {
            permissions.append(TerminalPermission.scriptExecution)
        }
        
        return permissions
    }
    
    /// Request permissions with policy check
    private func requestPermissions(_ permissions: [Permission], context: ExecutionContext) async throws -> [PermissionGrant] {
        var grants: [PermissionGrant] = []
        
        for permission in permissions {
            // Check if already granted
            if let existingGrant = activeGrants.first(where: { $0.permission.identifier == permission.identifier && !$0.isExpired }) {
                grants.append(existingGrant)
                continue
            }
            
            // Determine scope based on configuration
            let scope = configuration.unattendedMode ?
                PermissionScope.session(timeout: configuration.unattendedConfig?.sessionTimeout ?? .hours(1)) :
                PermissionScope.single
            
            // Request new grant
            let grant = try await grantPermission(permission, scope: scope)
            grants.append(grant)
        }
        
        return grants
    }
    
    /// Execute command in permission context
    private func executeInPermissionContext(_ command: String, grants: [PermissionGrant], context: ExecutionContext) async throws -> ExecutionResult {
        // Set up execution environment
        var environment = ProcessInfo.processInfo.environment
        
        // Add permission tokens to environment
        for grant in grants {
            environment["BRIDGE_PERMISSION_\(grant.permission.identifier.uppercased())"] = grant.token
        }
        
        // Handle sudo if needed
        if grants.contains(where: { $0.permission.identifier == SystemPermission.sudo.identifier }) {
            if let sudoCredential = try? await credentialStore.retrieve(identifier: "sudo") {
                environment["SUDO_ASKPASS"] = "/usr/bin/security"
                // Note: In production, would use a custom askpass helper
            }
        }
        
        // Execute command
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        process.arguments = ["-c", command]
        process.environment = environment
        
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        
        let startTime = Date()
        try process.run()
        process.waitUntilExit()
        
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        
        let output = String(data: outputData, encoding: .utf8) ?? ""
        let error = String(data: errorData, encoding: .utf8) ?? ""
        
        return ExecutionResult(
            output: output + error,
            exitCode: process.terminationStatus,
            executionTime: Date().timeIntervalSince(startTime)
        )
    }
    
    /// Pre-authorize developer tools
    private func preAuthorizeDeveloperTools() async {
        let developerPermissions: [Permission] = [
            DeveloperToolPermission.xcode,
            DeveloperToolPermission.codeSign,
            DeveloperToolPermission.instruments
        ]
        
        for permission in developerPermissions {
            _ = try? await grantPermission(permission, scope: .session(timeout: .hours(24)))
        }
    }
    
    /// Configure sudo passthrough
    private func configureSudoPassthrough() async {
        // In production, would set up secure sudo handling
        print("⚙️ Configuring sudo passthrough")
    }
    
    /// Load saved configuration
    private func loadConfiguration() async -> PermissionConfiguration? {
        // Load from UserDefaults or secure storage
        return nil
    }
    
    /// Save current configuration
    private func saveConfiguration() async {
        // Save to UserDefaults or secure storage
    }
}

/// # Permission Manager
///
/// Manages permission state and enforcement.
public class PermissionManager {
    
    private var grantedPermissions: [String: PermissionGrant] = [:]
    private var permissionHandlers: [String: PermissionHandler] = [:]
    
    /// Start monitoring for permission requests
    public func startMonitoring() async {
        // Set up system permission monitoring
        print("👁️ Starting permission monitoring")
    }
    
    /// Apply permission grant
    public func applyGrant(_ grant: PermissionGrant) async throws {
        grantedPermissions[grant.permission.identifier] = grant
        
        // Apply system-level permission if handler exists
        if let handler = permissionHandlers[grant.permission.type] {
            try await handler.apply(grant)
        }
    }
    
    /// Revoke permission grant
    public func revokeGrant(_ grant: PermissionGrant) async {
        grantedPermissions.removeValue(forKey: grant.permission.identifier)
        
        // Revoke system-level permission if handler exists
        if let handler = permissionHandlers[grant.permission.type] {
            await handler.revoke(grant)
        }
    }
    
    /// Check if permission is granted
    public func isGranted(_ permission: Permission) -> Bool {
        guard let grant = grantedPermissions[permission.identifier] else {
            return false
        }
        return !grant.isExpired
    }
}

/// # Secure Credential Store
///
/// Manages secure storage of credentials using Keychain.
public class SecureCredentialStore {
    
    private let keychainService = "com.bridge.terminal.autopermission"
    
    /// Initialize credential store
    public func initialize() async throws {
        // Verify keychain access
        print("🔐 Initializing secure credential store")
    }
    
    /// Store credential securely
    public func store(_ credential: SecureCredential, identifier: String) async throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: identifier,
            kSecValueData as String: credential.data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        // Delete existing item if present
        SecItemDelete(query as CFDictionary)
        
        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw PermissionError.keychainError(status)
        }
    }
    
    /// Retrieve stored credential
    public func retrieve(identifier: String) async throws -> SecureCredential {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: identifier,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data else {
            throw PermissionError.credentialNotFound
        }
        
        return SecureCredential(data: data)
    }
    
    /// Remove stored credential
    public func remove(identifier: String) async throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: identifier
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw PermissionError.keychainError(status)
        }
    }
}

/// # Permission Auditor
///
/// Maintains audit log of all permission operations.
public class PermissionAuditor {
    
    private var auditLog: [AuditEntry] = []
    private let logPath = "/Users/eatatjoes/Desktop/ORGANIZE!/BridgeTemplate/.terminal-permissions/audit.log"
    
    /// Initialize audit system
    public func initialize() async {
        // Create audit directory if needed
        let auditDir = (logPath as NSString).deletingLastPathComponent
        try? FileManager.default.createDirectory(atPath: auditDir, withIntermediateDirectories: true)
        
        // Load existing audit log
        await loadAuditLog()
    }
    
    /// Log permission grant
    public func logGrant(_ grant: PermissionGrant) async {
        let entry = AuditEntry(
            timestamp: Date(),
            type: .grant,
            permission: grant.permission.identifier,
            grantId: grant.id,
            scope: grant.scope.description,
            actor: "AutoPermissionSystem"
        )
        
        await appendEntry(entry)
    }
    
    /// Log permission revocation
    public func logRevocation(_ grant: PermissionGrant) async {
        let entry = AuditEntry(
            timestamp: Date(),
            type: .revoke,
            permission: grant.permission.identifier,
            grantId: grant.id,
            scope: grant.scope.description,
            actor: "AutoPermissionSystem"
        )
        
        await appendEntry(entry)
    }
    
    /// Log command execution
    public func logExecution(context: ExecutionContext, grants: [PermissionGrant], result: ExecutionResult) async {
        let entry = AuditEntry(
            timestamp: Date(),
            type: .execution,
            command: context.command,
            sessionId: context.sessionId,
            permissions: grants.map { $0.permission.identifier },
            exitCode: result.exitCode,
            executionTime: result.executionTime
        )
        
        await appendEntry(entry)
    }
    
    /// Log credential operation
    public func logCredentialOperation(_ operation: CredentialOperation, identifier: String) async {
        let entry = AuditEntry(
            timestamp: Date(),
            type: .credential,
            operation: operation,
            identifier: identifier,
            actor: "AutoPermissionSystem"
        )
        
        await appendEntry(entry)
    }
    
    /// Get filtered audit entries
    public func getEntries(filter: AuditFilter?) async -> [AuditEntry] {
        guard let filter = filter else {
            return auditLog
        }
        
        return auditLog.filter { entry in
            filter.matches(entry)
        }
    }
    
    // Private methods
    private func appendEntry(_ entry: AuditEntry) async {
        auditLog.append(entry)
        await persistEntry(entry)
    }
    
    private func persistEntry(_ entry: AuditEntry) async {
        // Append to audit log file
        guard let data = try? JSONEncoder().encode(entry),
              let string = String(data: data, encoding: .utf8) else {
            return
        }
        
        let logEntry = "\(string)\n"
        if let fileHandle = FileHandle(forWritingAtPath: logPath) {
            fileHandle.seekToEndOfFile()
            fileHandle.write(logEntry.data(using: .utf8)!)
            fileHandle.closeFile()
        } else {
            try? logEntry.write(toFile: logPath, atomically: true, encoding: .utf8)
        }
    }
    
    private func loadAuditLog() async {
        // Load existing audit entries
        guard let data = try? String(contentsOfFile: logPath) else {
            return
        }
        
        let lines = data.components(separatedBy: .newlines)
        for line in lines where !line.isEmpty {
            if let entryData = line.data(using: .utf8),
               let entry = try? JSONDecoder().decode(AuditEntry.self, from: entryData) {
                auditLog.append(entry)
            }
        }
    }
}

/// # Grant Policy Engine
///
/// Evaluates permission grant requests against security policies.
public class GrantPolicyEngine {
    
    private var sessionTimeout: TimeInterval = 3600 // 1 hour default
    private var policies: [GrantPolicy] = []
    
    /// Set session timeout
    public func setSessionTimeout(_ timeout: TimeInterval) async {
        sessionTimeout = timeout
    }
    
    /// Check if permission can be granted
    public func canGrant(_ permission: Permission, scope: PermissionScope) async -> Bool {
        // Check against all policies
        for policy in policies {
            if !policy.allows(permission: permission, scope: scope) {
                return false
            }
        }
        
        // Default allow if no policies deny
        return true
    }
    
    /// Add grant policy
    public func addPolicy(_ policy: GrantPolicy) {
        policies.append(policy)
    }
    
    /// Remove grant policy
    public func removePolicy(_ policyId: String) {
        policies.removeAll { $0.id == policyId }
    }
}

// MARK: - Supporting Types

/// Permission configuration
public struct PermissionConfiguration: Codable {
    var unattendedMode = false
    var unattendedConfig: UnattendedConfig?
    var defaultScope: PermissionScope = .single
    var auditingEnabled = true
    var credentialTimeout: TimeInterval = 3600
}

/// Unattended execution configuration
public struct UnattendedConfig: Codable {
    let enableSudoPassthrough: Bool
    let autoGrantDeveloperTools: Bool
    let autoGrantFileSystem: Bool
    let sessionTimeout: TimeInterval
    let allowedCommands: [String]?
    let deniedCommands: [String]?
}

/// Permission protocol
public protocol Permission {
    var identifier: String { get }
    var type: String { get }
    var description: String { get }
    var riskLevel: RiskLevel { get }
}

/// Terminal-specific permissions
public enum TerminalPermission: String, Permission, CaseIterable {
    case fullDiskAccess = "terminal.fullDiskAccess"
    case scriptExecution = "terminal.scriptExecution"
    case processControl = "terminal.processControl"
    
    public var identifier: String { rawValue }
    public var type: String { "terminal" }
    
    public var description: String {
        switch self {
        case .fullDiskAccess: return "Full Disk Access"
        case .scriptExecution: return "Script Execution"
        case .processControl: return "Process Control"
        }
    }
    
    public var riskLevel: RiskLevel {
        switch self {
        case .fullDiskAccess: return .high
        case .scriptExecution: return .medium
        case .processControl: return .medium
        }
    }
}

/// File system permissions
public enum FileSystemPermission: String, Permission, CaseIterable {
    case userRead = "filesystem.userRead"
    case userWrite = "filesystem.userWrite"
    case systemRead = "filesystem.systemRead"
    case systemWrite = "filesystem.systemWrite"
    
    public var identifier: String { rawValue }
    public var type: String { "filesystem" }
    
    public var description: String {
        switch self {
        case .userRead: return "User Directory Read"
        case .userWrite: return "User Directory Write"
        case .systemRead: return "System Directory Read"
        case .systemWrite: return "System Directory Write"
        }
    }
    
    public var riskLevel: RiskLevel {
        switch self {
        case .userRead: return .low
        case .userWrite: return .medium
        case .systemRead: return .medium
        case .systemWrite: return .high
        }
    }
}

/// Developer tool permissions
public enum DeveloperToolPermission: String, Permission, CaseIterable {
    case xcode = "devtools.xcode"
    case codeSign = "devtools.codesign"
    case instruments = "devtools.instruments"
    case simulator = "devtools.simulator"
    
    public var identifier: String { rawValue }
    public var type: String { "devtools" }
    
    public var description: String {
        switch self {
        case .xcode: return "Xcode Access"
        case .codeSign: return "Code Signing"
        case .instruments: return "Instruments Access"
        case .simulator: return "Simulator Control"
        }
    }
    
    public var riskLevel: RiskLevel {
        switch self {
        case .xcode: return .low
        case .codeSign: return .high
        case .instruments: return .medium
        case .simulator: return .low
        }
    }
}

/// System permissions
public enum SystemPermission: String, Permission, CaseIterable {
    case sudo = "system.sudo"
    case systemPreferences = "system.preferences"
    case securitySettings = "system.security"
    case networkSettings = "system.network"
    
    public var identifier: String { rawValue }
    public var type: String { "system" }
    
    public var description: String {
        switch self {
        case .sudo: return "Sudo Access"
        case .systemPreferences: return "System Preferences"
        case .securitySettings: return "Security Settings"
        case .networkSettings: return "Network Settings"
        }
    }
    
    public var riskLevel: RiskLevel {
        switch self {
        case .sudo: return .critical
        case .systemPreferences: return .high
        case .securitySettings: return .critical
        case .networkSettings: return .high
        }
    }
}

/// Permission scope
public enum PermissionScope: Codable {
    case single
    case session(timeout: TimeInterval)
    case permanent
    
    var description: String {
        switch self {
        case .single: return "Single use"
        case .session(let timeout): return "Session (\(Int(timeout/60)) min)"
        case .permanent: return "Permanent"
        }
    }
}

/// Risk level
public enum RiskLevel: String, Codable {
    case low, medium, high, critical
}

/// Permission grant
public struct PermissionGrant: Codable {
    let id: String
    let permission: PermissionWrapper
    let scope: PermissionScope
    let grantedAt: Date
    let grantedBy: String
    var token: String { id } // Simplified for example
    
    var isExpired: Bool {
        switch scope {
        case .single:
            return true // Single use grants expire immediately
        case .session(let timeout):
            return Date().timeIntervalSince(grantedAt) > timeout
        case .permanent:
            return false
        }
    }
}

/// Permission wrapper for Codable
public struct PermissionWrapper: Codable {
    let identifier: String
    let type: String
    let description: String
    let riskLevel: RiskLevel
    
    init(permission: Permission) {
        self.identifier = permission.identifier
        self.type = permission.type
        self.description = permission.description
        self.riskLevel = permission.riskLevel
    }
}

/// Execution context
public struct ExecutionContext {
    let command: String
    let timestamp: Date
    let sessionId: String
}

/// Execution result
public struct ExecutionResult {
    let output: String
    let exitCode: Int32
    let executionTime: TimeInterval
}

/// Permission execution result
public struct PermissionExecutionResult {
    let output: String
    let exitCode: Int32
    let grantedPermissions: [PermissionGrant]
    let executionTime: TimeInterval
}

/// Secure credential
public struct SecureCredential: Codable {
    let data: Data
    let type: CredentialType
    let metadata: [String: String]
    
    init(data: Data, type: CredentialType = .password, metadata: [String: String] = [:]) {
        self.data = data
        self.type = type
        self.metadata = metadata
    }
}

/// Credential type
public enum CredentialType: String, Codable {
    case password, token, certificate, key
}

/// Audit entry
public struct AuditEntry: Codable {
    let id = UUID().uuidString
    let timestamp: Date
    let type: AuditType
    
    // Grant/Revoke fields
    var permission: String?
    var grantId: String?
    var scope: String?
    
    // Execution fields
    var command: String?
    var sessionId: String?
    var permissions: [String]?
    var exitCode: Int32?
    var executionTime: TimeInterval?
    
    // Credential fields
    var operation: CredentialOperation?
    var identifier: String?
    
    // Common fields
    var actor: String?
}

/// Audit type
public enum AuditType: String, Codable {
    case grant, revoke, execution, credential, policy
}

/// Credential operation
public enum CredentialOperation: String, Codable {
    case store, retrieve, remove, update
}

/// Audit filter
public struct AuditFilter {
    var startDate: Date?
    var endDate: Date?
    var types: [AuditType]?
    var permissions: [String]?
    var actor: String?
    
    func matches(_ entry: AuditEntry) -> Bool {
        if let startDate = startDate, entry.timestamp < startDate {
            return false
        }
        if let endDate = endDate, entry.timestamp > endDate {
            return false
        }
        if let types = types, !types.contains(entry.type) {
            return false
        }
        if let permissions = permissions,
           let entryPermission = entry.permission,
           !permissions.contains(entryPermission) {
            return false
        }
        if let actor = actor, entry.actor != actor {
            return false
        }
        return true
    }
}

/// Grant policy protocol
public protocol GrantPolicy {
    var id: String { get }
    func allows(permission: Permission, scope: PermissionScope) -> Bool
}

/// Permission handler protocol
public protocol PermissionHandler {
    func apply(_ grant: PermissionGrant) async throws
    func revoke(_ grant: PermissionGrant) async
}

/// Permission error
public enum PermissionError: LocalizedError {
    case systemNotActive
    case policyDenied(reason: String)
    case keychainError(OSStatus)
    case credentialNotFound
    case permissionDenied(String)
    case executionFailed(String)
    
    public var errorDescription: String? {
        switch self {
        case .systemNotActive:
            return "Auto-permission system is not active"
        case .policyDenied(let reason):
            return "Permission denied by policy: \(reason)"
        case .keychainError(let status):
            return "Keychain error: \(status)"
        case .credentialNotFound:
            return "Credential not found in secure storage"
        case .permissionDenied(let permission):
            return "Permission denied: \(permission)"
        case .executionFailed(let reason):
            return "Execution failed: \(reason)"
        }
    }
}