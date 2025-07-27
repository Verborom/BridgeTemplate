import ArgumentParser
import UniversalTemplate
import Foundation

/// # Universal CLI
///
/// Command-line interface for UniversalTemplate operations.
/// Create, manage, and deploy components from the terminal.
@main
struct UniversalCLI: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "universal",
        abstract: "UniversalTemplate CLI - Create and manage components at any hierarchy level",
        version: "1.0.0",
        subcommands: [
            Create.self,
            List.self,
            Build.self,
            Test.self,
            Deploy.self,
            Migrate.self
        ]
    )
}

// MARK: - Create Command

struct Create: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Create a new component from template or configuration"
    )
    
    @Argument(help: "Component name")
    var name: String
    
    @Option(name: .shortAndLong, help: "Hierarchy level (module, feature, task, etc.)")
    var level: String = "component"
    
    @Option(name: .shortAndLong, help: "Component version")
    var version: String = "1.0.0"
    
    @Option(name: .shortAndLong, help: "Template to use")
    var template: String?
    
    @Option(name: .shortAndLong, help: "Output directory")
    var output: String = "."
    
    @MainActor
    func run() async throws {
        print("🚀 Creating \(level): \(name)")
        
        // Parse hierarchy level
        guard let hierarchyLevel = HierarchyLevel(rawValue: level.capitalized) else {
            throw ValidationError("Invalid hierarchy level: \(level)")
        }
        
        // Parse version
        let versionParts = version.split(separator: ".").compactMap { Int($0) }
        guard versionParts.count >= 3 else {
            throw ValidationError("Invalid version format. Use major.minor.patch")
        }
        
        let componentVersion = ComponentVersion(
            versionParts[0],
            versionParts[1],
            versionParts[2]
        )
        
        // Create component
        let factory = ComponentFactory.shared
        
        let config = ComponentCreationConfig(
            name: name,
            hierarchyLevel: hierarchyLevel,
            version: componentVersion
        )
        
        let component = try await factory.create(from: config)
        
        print("✅ Created \(hierarchyLevel.rawValue): \(name) v\(componentVersion)")
        
        // Generate files
        try await generateComponentFiles(
            component: component,
            outputDirectory: output
        )
    }
    
    @MainActor
    private func generateComponentFiles(
        component: any UniversalComponent,
        outputDirectory: String
    ) async throws {
        let fileManager = FileManager.default
        let componentDir = "\(outputDirectory)/\(component.name)"
        
        // Create directory structure
        try fileManager.createDirectory(
            atPath: componentDir,
            withIntermediateDirectories: true
        )
        
        // Generate Package.swift
        let packageContent = generatePackageFile(for: component)
        try packageContent.write(
            toFile: "\(componentDir)/Package.swift",
            atomically: true,
            encoding: .utf8
        )
        
        // Generate source file
        let sourceDir = "\(componentDir)/Sources/\(component.name)"
        try fileManager.createDirectory(
            atPath: sourceDir,
            withIntermediateDirectories: true
        )
        
        let sourceContent = generateSourceFile(for: component)
        try sourceContent.write(
            toFile: "\(sourceDir)/\(component.name).swift",
            atomically: true,
            encoding: .utf8
        )
        
        // Generate test file
        let testDir = "\(componentDir)/Tests/\(component.name)Tests"
        try fileManager.createDirectory(
            atPath: testDir,
            withIntermediateDirectories: true
        )
        
        let testContent = generateTestFile(for: component)
        try testContent.write(
            toFile: "\(testDir)/\(component.name)Tests.swift",
            atomically: true,
            encoding: .utf8
        )
        
        // Generate README
        let readmeContent = generateReadme(for: component)
        try readmeContent.write(
            toFile: "\(componentDir)/README.md",
            atomically: true,
            encoding: .utf8
        )
        
        // Generate CICD workflow
        let workflowDir = "\(componentDir)/.github/workflows"
        try fileManager.createDirectory(
            atPath: workflowDir,
            withIntermediateDirectories: true
        )
        
        let workflowContent = generateWorkflow(for: component)
        try workflowContent.write(
            toFile: "\(workflowDir)/ci.yml",
            atomically: true,
            encoding: .utf8
        )
        
        print("📁 Generated component files in: \(componentDir)")
    }
    
    @MainActor
    private func generatePackageFile(for component: any UniversalComponent) -> String {
        """
        // swift-tools-version: 5.9
        import PackageDescription
        
        let package = Package(
            name: "\(component.name)",
            platforms: [
                .macOS(.v14),
                .iOS(.v17)
            ],
            products: [
                .library(
                    name: "\(component.name)",
                    targets: ["\(component.name)"]
                )
            ],
            dependencies: [
                .package(path: "../UniversalTemplate")
            ],
            targets: [
                .target(
                    name: "\(component.name)",
                    dependencies: ["UniversalTemplate"]
                ),
                .testTarget(
                    name: "\(component.name)Tests",
                    dependencies: ["\(component.name)"]
                )
            ]
        )
        """
    }
    
    @MainActor
    private func generateSourceFile(for component: any UniversalComponent) -> String {
        """
        import SwiftUI
        import UniversalTemplate
        
        /// # \(component.name)
        ///
        /// \(component.description)
        @MainActor
        public class \(component.name): BaseComponent {
            
            public override init() {
                super.init()
                
                self.name = "\(component.name)"
                self.hierarchyLevel = .\(component.hierarchyLevel.rawValue.lowercased())
                self.version = ComponentVersion(\(component.version.major), \(component.version.minor), \(component.version.patch))
                self.icon = "\(component.icon)"
                self.description = "\(component.description)"
            }
            
            public override func createView() -> AnyView {
                AnyView(
                    VStack {
                        Text("\(component.name)")
                            .font(.title)
                        Text("\(component.hierarchyLevel.rawValue)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                )
            }
            
            public override func performExecution() async throws -> ComponentResult {
                // TODO: Implement component logic
                return ComponentResult(success: true, duration: 0.0)
            }
        }
        """
    }
    
    @MainActor
    private func generateTestFile(for component: any UniversalComponent) -> String {
        """
        import XCTest
        @testable import \(component.name)
        import UniversalTemplate
        
        @MainActor
        final class \(component.name)Tests: XCTestCase {
            
            func testComponentCreation() async throws {
                let component = \(component.name)()
                
                XCTAssertEqual(component.name, "\(component.name)")
                XCTAssertEqual(component.hierarchyLevel, .\(component.hierarchyLevel.rawValue.lowercased()))
            }
            
            func testComponentExecution() async throws {
                let component = \(component.name)()
                
                let result = try await component.execute()
                
                XCTAssertTrue(result.success)
            }
        }
        """
    }
    
    @MainActor
    private func generateReadme(for component: any UniversalComponent) -> String {
        """
        # \(component.name)
        
        \(component.description)
        
        ## Overview
        
        This is a \(component.hierarchyLevel.rawValue) component created with UniversalTemplate.
        
        - **Version**: \(component.version)
        - **Hierarchy Level**: \(component.hierarchyLevel.rawValue)
        - **Icon**: \(component.icon)
        
        ## Usage
        
        ```swift
        import \(component.name)
        
        let component = \(component.name)()
        try await component.initialize()
        
        // Use the component
        let result = try await component.execute()
        ```
        
        ## Development
        
        ### Building
        
        ```bash
        swift build
        ```
        
        ### Testing
        
        ```bash
        swift test
        ```
        
        ## License
        
        See LICENSE file.
        """
    }
    
    @MainActor
    private func generateWorkflow(for component: any UniversalComponent) -> String {
        """
        name: CI
        
        on:
          push:
            branches: [ main ]
          pull_request:
            branches: [ main ]
        
        jobs:
          build-and-test:
            uses: ../../.github/workflows/universal-component.yml
            with:
              component_path: .
              hierarchy_level: \(component.hierarchyLevel.rawValue.lowercased())
        """
    }
}

// MARK: - List Command

struct List: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "List all hierarchy levels"
    )
    
    func run() async throws {
        print("📋 Available Hierarchy Levels:\n")
        
        for level in HierarchyLevel.allCases {
            let icon = getIcon(for: level)
            print("\(icon) \(level.rawValue) (weight: \(level.weight))")
        }
        
        print("\n💡 Use any of these with: universal create <name> --level <level>")
    }
    
    private func getIcon(for level: HierarchyLevel) -> String {
        switch level {
        case .app: return "📱"
        case .module: return "📦"
        case .submodule: return "📂"
        case .epic: return "🏔️"
        case .story: return "📖"
        case .feature: return "⭐"
        case .component: return "🧩"
        case .widget: return "🪟"
        case .task: return "✅"
        case .subtask: return "📌"
        case .microservice: return "🔧"
        case .utility: return "🛠️"
        }
    }
}

// MARK: - Build Command

struct Build: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Build a component"
    )
    
    @Argument(help: "Component path")
    var path: String = "."
    
    @Option(name: .shortAndLong, help: "Configuration (debug/release)")
    var configuration: String = "debug"
    
    func run() async throws {
        print("🔨 Building component at: \(path)")
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/swift")
        process.arguments = ["build", "-c", configuration]
        process.currentDirectoryURL = URL(fileURLWithPath: path)
        
        try process.run()
        process.waitUntilExit()
        
        if process.terminationStatus == 0 {
            print("✅ Build successful!")
        } else {
            print("❌ Build failed with code: \(process.terminationStatus)")
        }
    }
}

// MARK: - Test Command

struct Test: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Test a component"
    )
    
    @Argument(help: "Component path")
    var path: String = "."
    
    @Flag(help: "Generate code coverage")
    var coverage = false
    
    func run() async throws {
        print("🧪 Testing component at: \(path)")
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/swift")
        
        var args = ["test"]
        if coverage {
            args.append("--enable-code-coverage")
        }
        
        process.arguments = args
        process.currentDirectoryURL = URL(fileURLWithPath: path)
        
        try process.run()
        process.waitUntilExit()
        
        if process.terminationStatus == 0 {
            print("✅ All tests passed!")
        } else {
            print("❌ Tests failed with code: \(process.terminationStatus)")
        }
    }
}

// MARK: - Deploy Command

struct Deploy: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Deploy a component"
    )
    
    @Argument(help: "Component path")
    var path: String = "."
    
    @Option(name: .shortAndLong, help: "Environment (development/staging/production)")
    var environment: String = "development"
    
    func run() async throws {
        print("🚀 Deploying component from: \(path)")
        print("📍 Target environment: \(environment)")
        
        // In a real implementation, this would:
        // 1. Build the component
        // 2. Run tests
        // 3. Package the component
        // 4. Deploy to the specified environment
        
        print("✅ Deployment simulation complete!")
        print("ℹ️  In production, this would deploy to \(environment)")
    }
}

// MARK: - Migrate Command

struct Migrate: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Migrate a component to a new version"
    )
    
    @Argument(help: "Component path")
    var path: String = "."
    
    @Option(name: .shortAndLong, help: "Target version")
    var target: String
    
    @Flag(help: "Dry run - show what would be done")
    var dryRun = false
    
    func run() async throws {
        print("🔄 Migrating component at: \(path)")
        print("📍 Target version: \(target)")
        
        if dryRun {
            print("🏃 Dry run mode - no changes will be made")
        }
        
        // In a real implementation, this would:
        // 1. Load the component
        // 2. Check current version
        // 3. Find migration path
        // 4. Apply migrations
        // 5. Update version
        
        print("✅ Migration simulation complete!")
    }
}

// MARK: - Validation Error

struct ValidationError: Error, CustomStringConvertible {
    let message: String
    var description: String { message }
    
    init(_ message: String) {
        self.message = message
    }
}