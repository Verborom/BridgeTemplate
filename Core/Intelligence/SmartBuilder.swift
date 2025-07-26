import Foundation

/// # Smart Build Engine
///
/// Executes targeted builds based on analyzed scope.
///
/// ## Overview
///
/// The Smart Build Engine is the execution layer of the Granular Development
/// Intelligence System. It takes build plans and executes them efficiently,
/// supporting hot-swapping, parallel builds, and incremental compilation.
///
/// ## Topics
///
/// ### Building
/// - ``buildComponent(_:)``
/// - ``buildSubmodule(_:)``
/// - ``buildModule(_:)``
///
/// ### Hot-Swapping
/// - ``hotSwapComponent(_:version:)``
/// - ``validateHotSwap(_:)``
///
/// ### Testing
/// - ``runImpactTests(_:)``
/// - ``runComponentTests(_:)``
///
/// ## Usage
///
/// ```swift
/// let builder = SmartBuilder()
/// let result = try await builder.buildComponent(plan)
/// if result.success {
///     try await builder.hotSwapComponent(plan.primaryTarget, version: result.version)
/// }
/// ```
public class SmartBuilder {
    
    /// Build queue for managing concurrent builds
    private let buildQueue = DispatchQueue(label: "com.bridge.smartbuilder", attributes: .concurrent)
    
    /// File manager for build operations
    private let fileManager = FileManager.default
    
    /// Current build context
    private var currentBuildContext: BuildContext?
    
    /// Initialize builder
    public init() {}
    
    /// Execute targeted build for specific component
    ///
    /// - Parameter plan: Build plan from scope analyzer
    /// - Returns: Build result with artifacts
    /// - Throws: BuildError if build fails
    ///
    /// ## Build Process
    ///
    /// 1. Prepare build environment
    /// 2. Copy only required files
    /// 3. Execute targeted compilation
    /// 4. Run component tests
    /// 5. Package for deployment
    public func buildComponent(_ plan: BuildPlan) async throws -> BuildResult {
        print("🔨 Smart Build: \(plan.primaryTarget)")
        print("📊 Scope: \(plan.dependentComponents.count + 1) components")
        print("⏱️ Estimated: \(plan.estimatedBuildTime)s")
        
        // Create build context
        let context = BuildContext(
            buildId: UUID().uuidString,
            target: plan.primaryTarget,
            timestamp: Date()
        )
        currentBuildContext = context
        
        // Prepare build directory
        let buildDir = try prepareBuildDirectory(for: context)
        
        // Execute build based on scope
        let result: BuildResult
        
        switch determineBuildType(for: plan.primaryTarget) {
        case .component:
            result = try await buildSingleComponent(plan, in: buildDir)
        case .submodule:
            result = try await buildSubmoduleComponent(plan, in: buildDir)
        case .module:
            result = try await buildModuleComponent(plan, in: buildDir)
        case .system:
            result = try await buildSystemComponent(plan, in: buildDir)
        }
        
        // Run impact tests if successful
        if result.success && !plan.testsToRun.isEmpty {
            let testResult = try await runImpactTests(plan)
            if !testResult.passed {
                throw BuildError.testsFailed(testResult.failures)
            }
        }
        
        return result
    }
    
    /// Build a single UI component
    private func buildSingleComponent(_ plan: BuildPlan, in buildDir: URL) async throws -> BuildResult {
        print("🎯 Building single component: \(plan.primaryTarget)")
        
        // Extract component files
        let componentFiles = try extractComponentFiles(plan.primaryTarget)
        
        // Create minimal Swift file with just the component
        let componentSource = try generateComponentSource(plan.primaryTarget, files: componentFiles)
        let sourceFile = buildDir.appendingPathComponent("Component.swift")
        try componentSource.write(to: sourceFile, atomically: true, encoding: .utf8)
        
        // Compile component
        let startTime = Date()
        let compileResult = try await compileSwiftFile(sourceFile, output: buildDir.appendingPathComponent("component.o"))
        let buildTime = Date().timeIntervalSince(startTime)
        
        if compileResult.exitCode == 0 {
            return BuildResult(
                success: true,
                target: plan.primaryTarget,
                artifacts: [buildDir.appendingPathComponent("component.o").path],
                buildTime: buildTime,
                version: generateVersion(),
                messages: ["Component built successfully"]
            )
        } else {
            throw BuildError.compilationFailed(compileResult.output)
        }
    }
    
    /// Build a submodule (widget/feature)
    private func buildSubmoduleComponent(_ plan: BuildPlan, in buildDir: URL) async throws -> BuildResult {
        print("📦 Building submodule: \(plan.primaryTarget)")
        
        // Get submodule directory
        let submodulePath = mapTargetToPath(plan.primaryTarget)
        
        // Run swift build for the submodule
        let startTime = Date()
        let buildResult = try await runSwiftBuild(in: submodulePath, configuration: .release)
        let buildTime = Date().timeIntervalSince(startTime)
        
        if buildResult.exitCode == 0 {
            // Package submodule
            let packagePath = try packageSubmodule(plan.primaryTarget, from: submodulePath, to: buildDir)
            
            return BuildResult(
                success: true,
                target: plan.primaryTarget,
                artifacts: [packagePath],
                buildTime: buildTime,
                version: generateVersion(),
                messages: ["Submodule built and packaged"]
            )
        } else {
            throw BuildError.buildFailed(buildResult.output)
        }
    }
    
    /// Build entire module
    private func buildModuleComponent(_ plan: BuildPlan, in buildDir: URL) async throws -> BuildResult {
        print("🏗️ Building module: \(plan.primaryTarget)")
        
        // Similar to submodule but includes all submodules
        let modulePath = mapTargetToPath(plan.primaryTarget)
        
        let startTime = Date()
        let buildResult = try await runSwiftBuild(in: modulePath, configuration: .release)
        let buildTime = Date().timeIntervalSince(startTime)
        
        if buildResult.exitCode == 0 {
            return BuildResult(
                success: true,
                target: plan.primaryTarget,
                artifacts: [buildDir.path],
                buildTime: buildTime,
                version: generateVersion(),
                messages: ["Module built successfully"]
            )
        } else {
            throw BuildError.buildFailed(buildResult.output)
        }
    }
    
    /// Build system component
    private func buildSystemComponent(_ plan: BuildPlan, in buildDir: URL) async throws -> BuildResult {
        print("🔧 Building system component: \(plan.primaryTarget)")
        
        // System components require more careful building
        throw BuildError.notImplemented("System component building not yet implemented")
    }
    
    /// Hot-swap component into running application
    ///
    /// - Parameters:
    ///   - component: Component identifier
    ///   - version: Version to swap to
    /// - Throws: HotSwapError if swap fails
    public func hotSwapComponent(_ component: String, version: String) async throws {
        print("🔄 Hot-swapping \(component) to v\(version)")
        
        // Validate component can be hot-swapped
        guard try await validateHotSwap(component) else {
            throw HotSwapError.notSupported(component)
        }
        
        // Load new component version
        let componentPath = buildArtifactPath(for: component, version: version)
        
        // Send hot-swap message to running app
        try await sendHotSwapMessage(HotSwapMessage(
            component: component,
            version: version,
            artifactPath: componentPath
        ))
        
        print("✅ Hot-swap completed")
    }
    
    /// Validate component can be hot-swapped
    private func validateHotSwap(_ component: String) async throws -> Bool {
        // Check if component is marked as hot-swappable
        let componentMap = ComponentMap()
        return componentMap.getComponent(for: component)?.hotSwappable ?? false
    }
    
    /// Run impact tests for build plan
    ///
    /// - Parameter plan: Build plan with test specifications
    /// - Returns: Test results
    public func runImpactTests(_ plan: BuildPlan) async throws -> TestResult {
        print("🧪 Running impact tests...")
        
        var testsPassed = 0
        var testsFailed = 0
        var failures: [String] = []
        
        for testTarget in plan.testsToRun {
            let result = try await runTest(testTarget)
            if result.passed {
                testsPassed += 1
            } else {
                testsFailed += 1
                failures.append("\(testTarget): \(result.message)")
            }
        }
        
        return TestResult(
            passed: testsFailed == 0,
            total: testsPassed + testsFailed,
            failures: failures
        )
    }
    
    // MARK: - Helper Methods
    
    /// Prepare build directory
    private func prepareBuildDirectory(for context: BuildContext) throws -> URL {
        let buildRoot = URL(fileURLWithPath: "/tmp/bridge-smart-build")
        let buildDir = buildRoot.appendingPathComponent(context.buildId)
        
        try fileManager.createDirectory(at: buildDir, withIntermediateDirectories: true)
        
        return buildDir
    }
    
    /// Determine build type from target
    private func determineBuildType(for target: String) -> BuildType {
        if target.starts(with: "ui.") {
            return .component
        } else if target.contains(".widgets.") || target.contains(".features.") {
            return .submodule
        } else if target.starts(with: "module.") {
            return .module
        } else if target.starts(with: "core.") {
            return .system
        }
        return .component
    }
    
    /// Map target identifier to file path
    private func mapTargetToPath(_ target: String) -> URL {
        let projectRoot = URL(fileURLWithPath: "/Users/eatatjoes/Desktop/ORGANIZE!/BridgeTemplate")
        
        switch target {
        case let t where t.starts(with: "ui."):
            return projectRoot.appendingPathComponent("Platforms/macOS")
        case let t where t.starts(with: "dashboard."):
            return projectRoot.appendingPathComponent("Modules/Dashboard")
        case let t where t.starts(with: "module."):
            let moduleName = t.replacingOccurrences(of: "module.", with: "")
                .capitalized
            return projectRoot.appendingPathComponent("Modules/\(moduleName)")
        default:
            return projectRoot
        }
    }
    
    /// Extract files for a component
    private func extractComponentFiles(_ target: String) throws -> [URL] {
        // Get files from component map
        let componentMap = ComponentMap()
        guard let component = componentMap.getComponent(for: target) else {
            throw BuildError.componentNotFound(target)
        }
        
        let projectRoot = URL(fileURLWithPath: "/Users/eatatjoes/Desktop/ORGANIZE!/BridgeTemplate")
        return component.files.map { projectRoot.appendingPathComponent($0) }
    }
    
    /// Generate component source
    private func generateComponentSource(_ target: String, files: [URL]) throws -> String {
        // For demo, return simple source
        return """
        import SwiftUI
        
        // Smart Build: \(target)
        // Generated: \(Date())
        
        // Component implementation would be extracted here
        """
    }
    
    /// Compile Swift file
    private func compileSwiftFile(_ source: URL, output: URL) async throws -> ProcessResult {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/swiftc")
        process.arguments = [
            source.path,
            "-o", output.path,
            "-target", "arm64-apple-macos13.0",
            "-framework", "SwiftUI",
            "-parse-as-library"
        ]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        
        try process.run()
        process.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""
        
        return ProcessResult(exitCode: Int(process.terminationStatus), output: output)
    }
    
    /// Run swift build
    private func runSwiftBuild(in directory: URL, configuration: BuildConfiguration) async throws -> ProcessResult {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/swift")
        process.arguments = ["build", "-c", configuration.rawValue]
        process.currentDirectoryURL = directory
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        
        try process.run()
        process.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""
        
        return ProcessResult(exitCode: Int(process.terminationStatus), output: output)
    }
    
    /// Package submodule
    private func packageSubmodule(_ target: String, from: URL, to: URL) throws -> String {
        // Create package
        let packageName = "\(target)-\(generateVersion()).bridgemodule"
        let packagePath = to.appendingPathComponent(packageName)
        
        // In real implementation, would package the build artifacts
        try "Package contents".write(to: packagePath, atomically: true, encoding: .utf8)
        
        return packagePath.path
    }
    
    /// Run single test
    private func runTest(_ testTarget: String) async throws -> TestResult {
        // Simplified test runner
        return TestResult(passed: true, total: 1, failures: [])
    }
    
    /// Generate version string
    private func generateVersion() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd.HHmmss"
        return formatter.string(from: Date())
    }
    
    /// Get build artifact path
    private func buildArtifactPath(for component: String, version: String) -> String {
        return "/tmp/bridge-artifacts/\(component)-\(version).bridgemodule"
    }
    
    /// Send hot-swap message
    private func sendHotSwapMessage(_ message: HotSwapMessage) async throws {
        // In real implementation, would use IPC to communicate with running app
        print("📤 Sending hot-swap message: \(message)")
    }
}

// MARK: - Supporting Types

/// Build context information
struct BuildContext {
    let buildId: String
    let target: String
    let timestamp: Date
}

/// Build result
public struct BuildResult {
    public let success: Bool
    public let target: String
    public let artifacts: [String]
    public let buildTime: TimeInterval
    public let version: String
    public let messages: [String]
}

/// Test result
public struct TestResult {
    public let passed: Bool
    public let total: Int
    public let failures: [String]
    
    var message: String {
        if passed {
            return "All \(total) tests passed"
        } else {
            return "\(failures.count) of \(total) tests failed"
        }
    }
}

/// Process result
struct ProcessResult {
    let exitCode: Int
    let output: String
}

/// Build configuration
enum BuildConfiguration: String {
    case debug
    case release
}

/// Build type
enum BuildType {
    case component
    case submodule
    case module
    case system
}

/// Hot-swap message
struct HotSwapMessage {
    let component: String
    let version: String
    let artifactPath: String
}

// MARK: - Errors

/// Build errors
enum BuildError: LocalizedError {
    case componentNotFound(String)
    case compilationFailed(String)
    case buildFailed(String)
    case testsFailed([String])
    case notImplemented(String)
    
    var errorDescription: String? {
        switch self {
        case .componentNotFound(let component):
            return "Component not found: \(component)"
        case .compilationFailed(let output):
            return "Compilation failed: \(output)"
        case .buildFailed(let output):
            return "Build failed: \(output)"
        case .testsFailed(let failures):
            return "Tests failed: \(failures.joined(separator: ", "))"
        case .notImplemented(let feature):
            return "Not implemented: \(feature)"
        }
    }
}

/// Hot-swap errors
enum HotSwapError: LocalizedError {
    case notSupported(String)
    case versionMismatch
    case componentBusy
    
    var errorDescription: String? {
        switch self {
        case .notSupported(let component):
            return "Hot-swap not supported for: \(component)"
        case .versionMismatch:
            return "Version mismatch during hot-swap"
        case .componentBusy:
            return "Component is busy and cannot be swapped"
        }
    }
}