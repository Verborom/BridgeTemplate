import Foundation
import SwiftUI

/// # TemplateInstantiator
///
/// The runtime engine that creates new components from UniversalTemplate at any hierarchy level.
/// This system enables users to click "New Epic", "New Feature", etc. and instantly create
/// fully-configured components with Git repositories, CICD, and proper integration.
///
/// ## Overview
///
/// TemplateInstantiator is the core of Bridge Template's dynamic component creation system.
/// It handles:
/// - Copying UniversalTemplate to the correct location
/// - Customizing the template with proper names and identifiers
/// - Setting up Git repositories with CICD workflows
/// - Integrating new components into the hierarchy
/// - Comprehensive error handling and validation
///
/// ## Topics
///
/// ### Component Creation
/// - ``createComponent(name:type:parentPath:configuration:)``
/// - ``createFromTemplate(config:)``
///
/// ### Template Management
/// - ``copyTemplate(to:)``
/// - ``customizeTemplate(at:with:)``
///
/// ### Git Integration
/// - ``initializeGitRepository(at:)``
/// - ``setupCICD(at:for:)``
///
/// ### Validation
/// - ``validateCreationRequest(_:)``
/// - ``validateHierarchyPath(_:)``
///
/// ## Version History
/// - v1.0.0: Initial implementation with full template instantiation
///
/// ## Usage
/// ```swift
/// let instantiator = TemplateInstantiator()
/// let config = ComponentCreationRequest(
///     name: "User Authentication",
///     type: .feature,
///     parentPath: "Modules/Dashboard/Features"
/// )
/// 
/// let result = try await instantiator.createComponent(from: config)
/// print("Created component at: \(result.path)")
/// ```
@MainActor
public class TemplateInstantiator: ObservableObject {
    
    // MARK: - Properties
    
    /// Singleton instance for global access
    public static let shared = TemplateInstantiator()
    
    /// File manager for filesystem operations
    private let fileManager = FileManager.default
    
    /// Base path to Bridge Template project
    private let projectRoot = "/Users/eatatjoes/Desktop/ORGANIZE!/BridgeTemplate"
    
    /// Path to UniversalTemplate
    private let templatePath: String
    
    /// Active creation operations for tracking
    @Published public private(set) var activeOperations: [UUID: CreationOperation] = [:]
    
    /// Creation history for debugging and rollback
    @Published public private(set) var creationHistory: [CreationResult] = []
    
    /// Error handler for comprehensive feedback
    private let errorHandler = TemplateErrorHandler()
    
    // MARK: - Initialization
    
    /// Initialize the template instantiator
    public init() {
        self.templatePath = "\(projectRoot)/UniversalTemplate"
    }
    
    // MARK: - Public API
    
    /// Create a new component from UniversalTemplate
    /// - Parameters:
    ///   - name: The name for the new component
    ///   - type: The hierarchy type (Epic, Feature, Task, etc.)
    ///   - parentPath: The parent directory path relative to project root
    ///   - configuration: Optional configuration overrides
    /// - Returns: Creation result with component details
    /// - Throws: TemplateError if creation fails
    public func createComponent(
        name: String,
        type: HierarchyType,
        parentPath: String,
        configuration: ComponentConfiguration? = nil
    ) async throws -> CreationResult {
        
        // Create operation tracker
        let operationId = UUID()
        let operation = CreationOperation(
            id: operationId,
            name: name,
            type: type,
            status: .initializing
        )
        
        await MainActor.run {
            activeOperations[operationId] = operation
        }
        
        do {
            // Validate request
            try validateComponentName(name)
            try validateHierarchyType(type)
            try await validateParentPath(parentPath)
            
            // Update status
            await updateOperationStatus(operationId, .copying)
            
            // Determine target path
            let targetPath = "\(projectRoot)/\(parentPath)/\(name.replacingOccurrences(of: " ", with: ""))"
            
            // Copy template
            try await copyTemplate(to: targetPath)
            
            // Update status
            await updateOperationStatus(operationId, .customizing)
            
            // Customize template
            let customization = TemplateCustomization(
                componentName: name,
                componentType: type,
                identifier: generateIdentifier(name: name, type: type),
                version: ComponentVersion(1, 0, 0),
                parentPath: parentPath
            )
            
            try await customizeTemplate(at: targetPath, with: customization)
            
            // Update status
            await updateOperationStatus(operationId, .initializingGit)
            
            // Initialize Git repository
            try await initializeGitRepository(at: targetPath)
            
            // Setup CICD
            try await setupCICD(at: targetPath, for: customization)
            
            // Update status
            await updateOperationStatus(operationId, .integrating)
            
            // Integrate with parent component
            try await integrateWithParent(
                componentPath: targetPath,
                parentPath: "\(projectRoot)/\(parentPath)",
                customization: customization
            )
            
            // Create success result
            let result = CreationResult(
                success: true,
                componentId: customization.identifier,
                name: name,
                type: type,
                path: targetPath,
                gitRepository: "\(targetPath)/.git",
                cicdConfigured: true,
                timestamp: Date()
            )
            
            // Update status
            await updateOperationStatus(operationId, .completed)
            
            // Record in history
            await MainActor.run {
                creationHistory.append(result)
                activeOperations.removeValue(forKey: operationId)
            }
            
            return result
            
        } catch {
            // Update status
            await updateOperationStatus(operationId, .failed(error.localizedDescription))
            
            // Create failure result
            let result = CreationResult(
                success: false,
                componentId: nil,
                name: name,
                type: type,
                path: nil,
                gitRepository: nil,
                cicdConfigured: false,
                timestamp: Date(),
                error: error.localizedDescription
            )
            
            // Record in history
            await MainActor.run {
                creationHistory.append(result)
                activeOperations.removeValue(forKey: operationId)
            }
            
            throw error
        }
    }
    
    /// Create multiple components in batch
    /// - Parameter requests: Array of creation requests
    /// - Returns: Array of creation results
    public func createComponents(
        _ requests: [ComponentCreationRequest]
    ) async -> [CreationResult] {
        
        var results: [CreationResult] = []
        
        for request in requests {
            do {
                let result = try await createComponent(
                    name: request.name,
                    type: request.type,
                    parentPath: request.parentPath,
                    configuration: request.configuration
                )
                results.append(result)
            } catch {
                let failureResult = CreationResult(
                    success: false,
                    componentId: nil,
                    name: request.name,
                    type: request.type,
                    path: nil,
                    gitRepository: nil,
                    cicdConfigured: false,
                    timestamp: Date(),
                    error: error.localizedDescription
                )
                results.append(failureResult)
            }
        }
        
        return results
    }
    
    // MARK: - Private Methods
    
    /// Copy UniversalTemplate to target location
    private func copyTemplate(to targetPath: String) async throws {
        
        // Check if template exists
        guard fileManager.fileExists(atPath: templatePath) else {
            throw TemplateError.templateNotFound(templatePath)
        }
        
        // Check if target already exists
        if fileManager.fileExists(atPath: targetPath) {
            throw TemplateError.targetAlreadyExists(targetPath)
        }
        
        // Create parent directory if needed
        let parentDir = (targetPath as NSString).deletingLastPathComponent
        if !fileManager.fileExists(atPath: parentDir) {
            try fileManager.createDirectory(
                atPath: parentDir,
                withIntermediateDirectories: true,
                attributes: nil
            )
        }
        
        // Copy template
        do {
            try fileManager.copyItem(atPath: templatePath, toPath: targetPath)
        } catch {
            throw TemplateError.copyFailed(error.localizedDescription)
        }
    }
    
    /// Customize template with component-specific values
    private func customizeTemplate(
        at path: String,
        with customization: TemplateCustomization
    ) async throws {
        
        // Files to customize
        let filesToCustomize = [
            "Package.swift",
            "README.md",
            "Sources/UniversalTemplate/UniversalComponent.swift",
            "Sources/UniversalTemplate/BaseComponent.swift",
            "Sources/UniversalTemplate/Examples/DashboardModule.swift",
            "Tests/UniversalTemplateTests/UniversalComponentTests.swift",
            "CICD/Workflows/universal-component.yml"
        ]
        
        for file in filesToCustomize {
            let filePath = "\(path)/\(file)"
            
            // Skip if file doesn't exist
            guard fileManager.fileExists(atPath: filePath) else { continue }
            
            // Read file
            let content = try String(contentsOfFile: filePath, encoding: .utf8)
            
            // Replace placeholders
            var newContent = content
            newContent = newContent.replacingOccurrences(
                of: "UniversalTemplate",
                with: customization.componentName.replacingOccurrences(of: " ", with: "")
            )
            newContent = newContent.replacingOccurrences(
                of: "universal-template",
                with: customization.componentName.lowercased().replacingOccurrences(of: " ", with: "-")
            )
            newContent = newContent.replacingOccurrences(
                of: "com.bridge.universal",
                with: customization.identifier
            )
            newContent = newContent.replacingOccurrences(
                of: "HierarchyLevel.module",
                with: "HierarchyLevel.\(customization.componentType.rawValue)"
            )
            
            // Write updated content
            try newContent.write(toFile: filePath, atomically: true, encoding: .utf8)
        }
        
        // Rename directories
        let sourceDir = "\(path)/Sources/UniversalTemplate"
        let targetDir = "\(path)/Sources/\(customization.componentName.replacingOccurrences(of: " ", with: ""))"
        
        if fileManager.fileExists(atPath: sourceDir) {
            try fileManager.moveItem(atPath: sourceDir, toPath: targetDir)
        }
        
        // Update test directory
        let testSourceDir = "\(path)/Tests/UniversalTemplateTests"
        let testTargetDir = "\(path)/Tests/\(customization.componentName.replacingOccurrences(of: " ", with: ""))Tests"
        
        if fileManager.fileExists(atPath: testSourceDir) {
            try fileManager.moveItem(atPath: testSourceDir, toPath: testTargetDir)
        }
    }
    
    /// Initialize Git repository for the new component
    private func initializeGitRepository(at path: String) async throws {
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        process.arguments = ["init"]
        process.currentDirectoryURL = URL(fileURLWithPath: path)
        
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        
        do {
            try process.run()
            process.waitUntilExit()
            
            if process.terminationStatus != 0 {
                let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
                let errorString = String(data: errorData, encoding: .utf8) ?? "Unknown error"
                throw TemplateError.gitInitFailed(errorString)
            }
            
            // Add initial commit
            try await gitAddAndCommit(
                at: path,
                message: "Initial commit - Component created from UniversalTemplate"
            )
            
        } catch {
            throw TemplateError.gitInitFailed(error.localizedDescription)
        }
    }
    
    /// Setup CICD workflows for the component
    private func setupCICD(
        at path: String,
        for customization: TemplateCustomization
    ) async throws {
        
        let workflowPath = "\(path)/CICD/Workflows/universal-component.yml"
        
        guard fileManager.fileExists(atPath: workflowPath) else {
            throw TemplateError.cicdSetupFailed("Workflow file not found")
        }
        
        // Additional CICD customization if needed
        var content = try String(contentsOfFile: workflowPath, encoding: .utf8)
        
        // Update workflow name
        content = content.replacingOccurrences(
            of: "name: Universal Component CICD",
            with: "name: \(customization.componentName) CICD"
        )
        
        // Update component-specific settings
        content = content.replacingOccurrences(
            of: "COMPONENT_NAME: UniversalTemplate",
            with: "COMPONENT_NAME: \(customization.componentName)"
        )
        
        content = content.replacingOccurrences(
            of: "HIERARCHY_LEVEL: module",
            with: "HIERARCHY_LEVEL: \(customization.componentType.rawValue)"
        )
        
        try content.write(toFile: workflowPath, atomically: true, encoding: .utf8)
    }
    
    /// Integrate new component with parent
    private func integrateWithParent(
        componentPath: String,
        parentPath: String,
        customization: TemplateCustomization
    ) async throws {
        
        // Find parent Package.swift
        let parentPackagePath = "\(parentPath)/Package.swift"
        
        if fileManager.fileExists(atPath: parentPackagePath) {
            // Read parent package
            var content = try String(contentsOfFile: parentPackagePath, encoding: .utf8)
            
            // Add dependency
            let dependencyLine = """
                .package(path: "./\(customization.componentName.replacingOccurrences(of: " ", with: ""))"),
            """
            
            // Find dependencies array and add new dependency
            if let dependenciesRange = content.range(of: "dependencies: [") {
                let insertIndex = content.index(dependenciesRange.upperBound, offsetBy: 1)
                content.insert(contentsOf: "\n        \(dependencyLine)", at: insertIndex)
                
                // Write updated package
                try content.write(toFile: parentPackagePath, atomically: true, encoding: .utf8)
            }
        }
        
        // Update parent component registry if it exists
        let registryPath = "\(parentPath)/Sources/ComponentRegistry.swift"
        if fileManager.fileExists(atPath: registryPath) {
            // Add component registration logic here
        }
    }
    
    // MARK: - Validation Methods
    
    /// Validate component name
    private func validateComponentName(_ name: String) throws {
        guard !name.isEmpty else {
            throw TemplateError.invalidName("Component name cannot be empty")
        }
        
        guard name.count <= 100 else {
            throw TemplateError.invalidName("Component name too long (max 100 characters)")
        }
        
        let invalidCharacters = CharacterSet.alphanumerics.inverted.subtracting(.whitespaces)
        guard name.rangeOfCharacter(from: invalidCharacters) == nil else {
            throw TemplateError.invalidName("Component name contains invalid characters")
        }
    }
    
    /// Validate hierarchy type
    private func validateHierarchyType(_ type: HierarchyType) throws {
        // All types are valid in our system
        // This is here for future validation logic
    }
    
    /// Validate parent path exists
    private func validateParentPath(_ path: String) async throws {
        let fullPath = "\(projectRoot)/\(path)"
        
        guard fileManager.fileExists(atPath: fullPath) else {
            throw TemplateError.parentNotFound(path)
        }
        
        var isDirectory: ObjCBool = false
        guard fileManager.fileExists(atPath: fullPath, isDirectory: &isDirectory),
              isDirectory.boolValue else {
            throw TemplateError.parentNotDirectory(path)
        }
    }
    
    // MARK: - Helper Methods
    
    /// Generate component identifier
    private func generateIdentifier(name: String, type: HierarchyType) -> String {
        let cleanName = name.lowercased()
            .replacingOccurrences(of: " ", with: ".")
            .replacingOccurrences(of: "-", with: ".")
        
        return "com.bridge.\(type.rawValue).\(cleanName)"
    }
    
    /// Update operation status
    private func updateOperationStatus(_ id: UUID, _ status: OperationStatus) async {
        await MainActor.run {
            activeOperations[id]?.status = status
            activeOperations[id]?.lastUpdated = Date()
        }
    }
    
    /// Git add and commit helper
    private func gitAddAndCommit(at path: String, message: String) async throws {
        // Git add
        let addProcess = Process()
        addProcess.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        addProcess.arguments = ["add", "."]
        addProcess.currentDirectoryURL = URL(fileURLWithPath: path)
        
        try addProcess.run()
        addProcess.waitUntilExit()
        
        guard addProcess.terminationStatus == 0 else {
            throw TemplateError.gitOperationFailed("Failed to add files")
        }
        
        // Git commit
        let commitProcess = Process()
        commitProcess.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        commitProcess.arguments = ["commit", "-m", message]
        commitProcess.currentDirectoryURL = URL(fileURLWithPath: path)
        
        try commitProcess.run()
        commitProcess.waitUntilExit()
        
        guard commitProcess.terminationStatus == 0 else {
            throw TemplateError.gitOperationFailed("Failed to commit")
        }
    }
}

// MARK: - Supporting Types

/// Component hierarchy types
public enum HierarchyType: String, CaseIterable {
    case app = "app"
    case module = "module"
    case submodule = "submodule"
    case epic = "epic"
    case story = "story"
    case feature = "feature"
    case component = "component"
    case widget = "widget"
    case task = "task"
    case subtask = "subtask"
    case microservice = "microservice"
    case utility = "utility"
}

/// Component creation request
public struct ComponentCreationRequest {
    public let name: String
    public let type: HierarchyType
    public let parentPath: String
    public let configuration: ComponentConfiguration?
    
    public init(
        name: String,
        type: HierarchyType,
        parentPath: String,
        configuration: ComponentConfiguration? = nil
    ) {
        self.name = name
        self.type = type
        self.parentPath = parentPath
        self.configuration = configuration
    }
}

/// Component configuration
public struct ComponentConfiguration {
    public let theme: String?
    public let features: [String]?
    public let permissions: [String]?
    public let customProperties: [String: Any]?
    
    public init(
        theme: String? = nil,
        features: [String]? = nil,
        permissions: [String]? = nil,
        customProperties: [String: Any]? = nil
    ) {
        self.theme = theme
        self.features = features
        self.permissions = permissions
        self.customProperties = customProperties
    }
}

/// Template customization data
struct TemplateCustomization {
    let componentName: String
    let componentType: HierarchyType
    let identifier: String
    let version: ComponentVersion
    let parentPath: String
}

/// Component version
public struct ComponentVersion {
    public let major: Int
    public let minor: Int
    public let patch: Int
    
    public init(_ major: Int, _ minor: Int, _ patch: Int) {
        self.major = major
        self.minor = minor
        self.patch = patch
    }
    
    var string: String {
        "\(major).\(minor).\(patch)"
    }
}

/// Creation operation tracking
public struct CreationOperation {
    public let id: UUID
    public let name: String
    public let type: HierarchyType
    public var status: OperationStatus
    public var lastUpdated: Date = Date()
}

/// Operation status
public enum OperationStatus {
    case initializing
    case copying
    case customizing
    case initializingGit
    case integrating
    case completed
    case failed(String)
}

/// Creation result
public struct CreationResult {
    public let success: Bool
    public let componentId: String?
    public let name: String
    public let type: HierarchyType
    public let path: String?
    public let gitRepository: String?
    public let cicdConfigured: Bool
    public let timestamp: Date
    public let error: String?
}

/// Template errors
public enum TemplateError: LocalizedError {
    case templateNotFound(String)
    case targetAlreadyExists(String)
    case copyFailed(String)
    case customizationFailed(String)
    case gitInitFailed(String)
    case gitOperationFailed(String)
    case cicdSetupFailed(String)
    case integrationFailed(String)
    case invalidName(String)
    case parentNotFound(String)
    case parentNotDirectory(String)
    case unknownError(String)
    
    public var errorDescription: String? {
        switch self {
        case .templateNotFound(let path):
            return "Template not found at: \(path)"
        case .targetAlreadyExists(let path):
            return "Target already exists at: \(path)"
        case .copyFailed(let reason):
            return "Failed to copy template: \(reason)"
        case .customizationFailed(let reason):
            return "Failed to customize template: \(reason)"
        case .gitInitFailed(let reason):
            return "Failed to initialize Git repository: \(reason)"
        case .gitOperationFailed(let reason):
            return "Git operation failed: \(reason)"
        case .cicdSetupFailed(let reason):
            return "Failed to setup CICD: \(reason)"
        case .integrationFailed(let reason):
            return "Failed to integrate with parent: \(reason)"
        case .invalidName(let reason):
            return "Invalid component name: \(reason)"
        case .parentNotFound(let path):
            return "Parent directory not found: \(path)"
        case .parentNotDirectory(let path):
            return "Parent path is not a directory: \(path)"
        case .unknownError(let reason):
            return "Unknown error: \(reason)"
        }
    }
}

/// Template error handler for comprehensive feedback
class TemplateErrorHandler {
    
    func handleError(_ error: Error) -> String {
        if let templateError = error as? TemplateError {
            return templateError.errorDescription ?? "Unknown template error"
        }
        
        return error.localizedDescription
    }
    
    func suggestFix(for error: TemplateError) -> String? {
        switch error {
        case .templateNotFound:
            return "Ensure UniversalTemplate exists at the expected location"
        case .targetAlreadyExists:
            return "Choose a different name or remove the existing component"
        case .copyFailed:
            return "Check filesystem permissions and available disk space"
        case .gitInitFailed:
            return "Ensure Git is installed and accessible"
        case .parentNotFound:
            return "Create the parent directory first or choose an existing location"
        case .invalidName:
            return "Use only letters, numbers, and spaces in the component name"
        default:
            return nil
        }
    }
}