import SwiftUI

/// # ComponentCreationView
///
/// A SwiftUI view that provides the user interface for creating new components
/// at any hierarchy level using the TemplateInstantiator system.
///
/// ## Overview
///
/// This view enables users to click buttons like "New Epic", "New Feature", etc.
/// and create fully-configured components with Git repositories and CICD.
/// It provides:
/// - Type selection (Epic, Feature, Task, etc.)
/// - Name input with validation
/// - Parent path selection
/// - Real-time creation progress
/// - Error handling with recovery suggestions
///
/// ## Topics
///
/// ### View Components
/// - ``creationSheet``
/// - ``progressView``
/// - ``successView``
/// - ``errorView``
///
/// ## Version History
/// - v1.0.0: Initial implementation with full creation UI
///
/// ## Usage
/// ```swift
/// ComponentCreationView(
///     parentPath: "Modules/Dashboard/Features",
///     onCreated: { result in
///         print("Created: \(result.name)")
///     }
/// )
/// ```
public struct ComponentCreationView: View {
    
    // MARK: - Properties
    
    /// Parent path for the new component
    public let parentPath: String
    
    /// Callback when component is created
    public let onCreated: ((CreationResult) -> Void)?
    
    /// Callback when view is dismissed
    public let onDismiss: (() -> Void)?
    
    /// Template instantiator instance
    @StateObject private var instantiator = TemplateInstantiator.shared
    
    /// View state
    @State private var componentName = ""
    @State private var selectedType: HierarchyType = .feature
    @State private var isCreating = false
    @State private var creationResult: CreationResult?
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var currentOperation: CreationOperation?
    
    /// Form validation
    private var isFormValid: Bool {
        !componentName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        componentName.count <= 100
    }
    
    // MARK: - Initialization
    
    public init(
        parentPath: String,
        onCreated: ((CreationResult) -> Void)? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        self.parentPath = parentPath
        self.onCreated = onCreated
        self.onDismiss = onDismiss
    }
    
    // MARK: - Body
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if isCreating {
                    progressView
                } else if let result = creationResult {
                    successView(result)
                } else {
                    creationForm
                }
            }
            .navigationTitle("Create New Component")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onDismiss?()
                    }
                    .disabled(isCreating)
                }
            }
            .alert("Creation Error", isPresented: $showError) {
                Button("OK") {
                    showError = false
                }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    // MARK: - Subviews
    
    /// Main creation form
    private var creationForm: some View {
        Form {
            Section {
                TextField("Component Name", text: $componentName)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.words)
                
                if !componentName.isEmpty && componentName.count > 100 {
                    Label("Name too long (max 100 characters)", systemImage: "exclamationmark.triangle")
                        .foregroundColor(.red)
                        .font(.caption)
                }
            } header: {
                Text("Component Name")
            } footer: {
                Text("Enter a descriptive name for your component")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Section {
                Picker("Type", selection: $selectedType) {
                    ForEach(HierarchyType.allCases, id: \.self) { type in
                        Label(
                            type.displayName,
                            systemImage: type.icon
                        )
                        .tag(type)
                    }
                }
                .pickerStyle(.menu)
            } header: {
                Text("Component Type")
            } footer: {
                Text(selectedType.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Section {
                Label(parentPath, systemImage: "folder")
                    .font(.system(.body, design: .monospaced))
            } header: {
                Text("Parent Location")
            }
            
            Section {
                Text("This will create:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                VStack(alignment: .leading, spacing: 8) {
                    Label("Complete Swift package", systemImage: "shippingbox")
                    Label("Git repository with initial commit", systemImage: "arrow.triangle.branch")
                    Label("GitHub Actions CICD workflow", systemImage: "gearshape.2")
                    Label("Integrated with parent component", systemImage: "link")
                    Label("Ready for development", systemImage: "checkmark.circle")
                }
                .font(.footnote)
                .padding(.vertical, 4)
            }
            
            Section {
                Button(action: createComponent) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Create \(selectedType.displayName)")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!isFormValid)
            }
        }
    }
    
    /// Progress view during creation
    private var progressView: some View {
        VStack(spacing: 24) {
            ProgressView()
                .scaleEffect(1.5)
                .padding()
            
            Text("Creating \(componentName)")
                .font(.headline)
            
            if let operation = currentOperation {
                VStack(spacing: 12) {
                    statusRow(for: operation.status)
                    
                    Text("Please wait...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(12)
            }
            
            Spacer()
        }
        .padding()
    }
    
    /// Success view after creation
    private func successView(_ result: CreationResult) -> some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 72))
                .foregroundColor(.green)
            
            Text("Successfully Created!")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 16) {
                InfoRow(
                    icon: "tag",
                    label: "Name",
                    value: result.name
                )
                
                InfoRow(
                    icon: "square.stack.3d.up",
                    label: "Type",
                    value: result.type.displayName
                )
                
                if let path = result.path {
                    InfoRow(
                        icon: "folder",
                        label: "Location",
                        value: path.replacingOccurrences(
                            of: "/Users/eatatjoes/Desktop/ORGANIZE!/BridgeTemplate/",
                            with: ""
                        ),
                        isMonospaced: true
                    )
                }
                
                if result.gitRepository != nil {
                    InfoRow(
                        icon: "arrow.triangle.branch",
                        label: "Git",
                        value: "Repository initialized"
                    )
                }
                
                if result.cicdConfigured {
                    InfoRow(
                        icon: "gearshape.2",
                        label: "CICD",
                        value: "GitHub Actions configured"
                    )
                }
            }
            .padding()
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(12)
            
            HStack(spacing: 16) {
                Button("Create Another") {
                    resetForm()
                }
                .buttonStyle(.bordered)
                
                Button("Done") {
                    onCreated?(result)
                    onDismiss?()
                }
                .buttonStyle(.borderedProminent)
            }
            
            Spacer()
        }
        .padding()
    }
    
    // MARK: - Helper Views
    
    /// Status row for progress display
    private func statusRow(for status: OperationStatus) -> some View {
        HStack {
            switch status {
            case .initializing:
                ProgressView()
                    .scaleEffect(0.8)
                Text("Initializing...")
            case .copying:
                ProgressView()
                    .scaleEffect(0.8)
                Text("Copying template...")
            case .customizing:
                ProgressView()
                    .scaleEffect(0.8)
                Text("Customizing component...")
            case .initializingGit:
                ProgressView()
                    .scaleEffect(0.8)
                Text("Setting up Git repository...")
            case .integrating:
                ProgressView()
                    .scaleEffect(0.8)
                Text("Integrating with parent...")
            case .completed:
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Text("Completed!")
            case .failed(let error):
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
                Text("Failed: \(error)")
                    .lineLimit(2)
            }
        }
        .font(.footnote)
    }
    
    // MARK: - Actions
    
    /// Create the component
    private func createComponent() {
        guard isFormValid else { return }
        
        isCreating = true
        
        Task {
            // Monitor active operations
            let cancellable = instantiator.$activeOperations
                .compactMap { operations in
                    operations.values.first { $0.name == self.componentName }
                }
                .sink { operation in
                    self.currentOperation = operation
                }
            
            do {
                let result = try await instantiator.createComponent(
                    name: componentName,
                    type: selectedType,
                    parentPath: parentPath,
                    configuration: nil
                )
                
                await MainActor.run {
                    self.creationResult = result
                    self.isCreating = false
                }
                
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                    self.isCreating = false
                }
            }
            
            cancellable.cancel()
        }
    }
    
    /// Reset form to initial state
    private func resetForm() {
        componentName = ""
        selectedType = .feature
        creationResult = nil
        currentOperation = nil
    }
}

// MARK: - Supporting Views

/// Information row for displaying results
struct InfoRow: View {
    let icon: String
    let label: String
    let value: String
    var isMonospaced = false
    
    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(isMonospaced ? .system(.footnote, design: .monospaced) : .footnote)
                    .fontWeight(.medium)
            }
            
            Spacer()
        }
    }
}

// MARK: - Extensions

extension HierarchyType {
    /// Display name for UI
    var displayName: String {
        switch self {
        case .app: return "Application"
        case .module: return "Module"
        case .submodule: return "Submodule"
        case .epic: return "Epic"
        case .story: return "Story"
        case .feature: return "Feature"
        case .component: return "Component"
        case .widget: return "Widget"
        case .task: return "Task"
        case .subtask: return "Subtask"
        case .microservice: return "Microservice"
        case .utility: return "Utility"
        }
    }
    
    /// Icon for UI
    var icon: String {
        switch self {
        case .app: return "app"
        case .module: return "square.grid.2x2"
        case .submodule: return "square.grid.2x2.fill"
        case .epic: return "star.circle"
        case .story: return "book.closed"
        case .feature: return "star"
        case .component: return "cube"
        case .widget: return "uiwindow.split.2x1"
        case .task: return "checkmark.circle"
        case .subtask: return "checkmark.circle.fill"
        case .microservice: return "server.rack"
        case .utility: return "wrench"
        }
    }
    
    /// Description for UI
    var description: String {
        switch self {
        case .app: return "Top-level application container"
        case .module: return "Major functional area with submodules"
        case .submodule: return "Subdivision of a module"
        case .epic: return "Large feature set or initiative"
        case .story: return "User story or requirement"
        case .feature: return "Individual feature implementation"
        case .component: return "Reusable UI or logic component"
        case .widget: return "Small UI widget or control"
        case .task: return "Specific development task"
        case .subtask: return "Subdivision of a task"
        case .microservice: return "Independent service component"
        case .utility: return "Helper or utility component"
        }
    }
}

// MARK: - Preview

#if DEBUG
struct ComponentCreationView_Previews: PreviewProvider {
    static var previews: some View {
        ComponentCreationView(
            parentPath: "Modules/Dashboard/Features",
            onCreated: { result in
                print("Created: \(result.name)")
            }
        )
    }
}
#endif