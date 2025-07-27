import SwiftUI

/// # ExampleIntegration
///
/// Demonstrates how to integrate the TemplateInstantiator system into
/// existing modules and views for runtime component creation.
///
/// ## Overview
///
/// This file shows various integration patterns for adding "New Component"
/// functionality to different parts of your application.
///
/// ## Topics
///
/// ### Integration Examples
/// - ``DashboardWithCreation``
/// - ``ProjectsViewWithCreation``
/// - ``FeatureListWithCreation``
///
/// ## Version History
/// - v1.0.0: Initial examples
///
/// ## Usage
/// Copy these patterns into your actual modules and customize as needed.

// MARK: - Dashboard Integration Example

/// Example: Dashboard module with component creation
struct DashboardWithCreation: View {
    
    @State private var features: [String] = ["Analytics", "Reports", "Settings"]
    @State private var recentlyCreated: CreationResult?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header with creation button
                    HStack {
                        Text("Dashboard Features")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        CreateComponentButton.feature(
                            parentPath: "Modules/Dashboard/Features",
                            style: .prominent
                        ) { result in
                            // Handle creation
                            recentlyCreated = result
                            features.append(result.name)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Recently created notification
                    if let recent = recentlyCreated {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Created: \(recent.name)")
                            Spacer()
                        }
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }
                    
                    // Feature grid
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ForEach(features, id: \.self) { feature in
                            FeatureCard(name: feature)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    CreateComponentMenu(
                        parentPath: "Modules/Dashboard",
                        types: [.submodule, .feature, .widget],
                        label: "Add",
                        icon: "plus.circle"
                    )
                }
            }
        }
    }
}

// MARK: - Projects View Integration Example

/// Example: Projects module with epic/story creation
struct ProjectsViewWithCreation: View {
    
    @State private var projects = [
        Project(name: "Mobile App", epics: ["User Auth", "Dashboard"]),
        Project(name: "Web Platform", epics: ["API", "Frontend"])
    ]
    @State private var selectedProject: Project?
    
    var body: some View {
        NavigationSplitView {
            // Project list
            List(selection: $selectedProject) {
                ForEach(projects) { project in
                    NavigationLink(value: project) {
                        Label(project.name, systemImage: "folder")
                    }
                }
            }
            .navigationTitle("Projects")
            .toolbar {
                ToolbarItem {
                    CreateComponentButton(
                        type: .module,
                        parentPath: "Modules/Projects",
                        style: .toolbar,
                        label: "New Project"
                    )
                }
            }
        } detail: {
            if let project = selectedProject {
                // Project detail with epic creation
                ProjectDetailView(project: project)
                    .componentCreationToolbar(
                        parentPath: "Modules/Projects/\(project.name.replacingOccurrences(of: " ", with: ""))/Epics",
                        types: [.epic, .story],
                        placement: .primaryAction
                    ) { result in
                        // Update project with new epic
                        if let index = projects.firstIndex(where: { $0.id == project.id }) {
                            projects[index].epics.append(result.name)
                        }
                    }
            } else {
                Text("Select a project")
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Feature List Integration Example

/// Example: Feature list with inline creation
struct FeatureListWithCreation: View {
    
    let modulePath: String
    @State private var features: [Feature] = []
    @State private var showingCreation = false
    
    var body: some View {
        List {
            // Existing features
            ForEach(features) { feature in
                FeatureRow(feature: feature)
                    .swipeActions(edge: .trailing) {
                        CreateComponentButton(
                            type: .task,
                            parentPath: "\(modulePath)/Features/\(feature.name)/Tasks",
                            style: .iconOnly,
                            icon: "plus",
                            color: .blue
                        ) { result in
                            // Add task to feature
                            if let index = features.firstIndex(where: { $0.id == feature.id }) {
                                features[index].tasks.append(result.name)
                            }
                        }
                    }
            }
            
            // Inline creation button
            Section {
                CreateComponentButton(
                    type: .feature,
                    parentPath: "\(modulePath)/Features",
                    style: .compact
                ) { result in
                    features.append(Feature(
                        name: result.name,
                        path: result.path ?? ""
                    ))
                }
                .listRowBackground(Color.clear)
            }
        }
        .navigationTitle("Features")
    }
}

// MARK: - Card-based Integration Example

/// Example: Card UI with creation
struct ComponentCard: View {
    
    let title: String
    let type: HierarchyType
    let path: String
    let isEmpty: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            if isEmpty {
                // Empty state with creation
                VStack(spacing: 16) {
                    Image(systemName: type.icon)
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    
                    Text("No \(type.displayName)s yet")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    CreateComponentButton(
                        type: type,
                        parentPath: path,
                        style: .prominent
                    )
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            } else {
                // Content with header creation button
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(title)
                            .font(.headline)
                        
                        Spacer()
                        
                        CreateComponentButton(
                            type: type,
                            parentPath: path,
                            style: .iconOnly,
                            icon: "plus.circle"
                        )
                    }
                    
                    // Component content here
                    Text("Component content...")
                        .foregroundColor(.secondary)
                }
                .padding()
            }
        }
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Contextual Menu Integration

/// Example: Right-click context menu with creation
struct ComponentListWithContextMenu: View {
    
    let components: [String]
    let parentPath: String
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(components, id: \.self) { component in
                    Text(component)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            .padding()
        }
        .contextMenu {
            CreateComponentMenu(
                parentPath: parentPath,
                types: [.feature, .component, .widget],
                label: "Create New"
            )
        }
    }
}

// MARK: - Supporting Types

struct Project: Identifiable, Hashable {
    let id = UUID()
    let name: String
    var epics: [String]
}

struct Feature: Identifiable {
    let id = UUID()
    let name: String
    let path: String
    var tasks: [String] = []
}

struct FeatureCard: View {
    let name: String
    
    var body: some View {
        VStack {
            Image(systemName: "star.fill")
                .font(.largeTitle)
                .foregroundColor(.yellow)
            Text(name)
                .font(.headline)
        }
        .frame(height: 120)
        .frame(maxWidth: .infinity)
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(12)
    }
}

struct ProjectDetailView: View {
    let project: Project
    
    var body: some View {
        List {
            Section("Epics") {
                ForEach(project.epics, id: \.self) { epic in
                    Label(epic, systemImage: "star.circle")
                }
            }
        }
        .navigationTitle(project.name)
    }
}

struct FeatureRow: View {
    let feature: Feature
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(feature.name)
                .font(.headline)
            Text("\(feature.tasks.count) tasks")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Usage Documentation

/*
 
 INTEGRATION GUIDE:
 
 1. Basic Button Integration:
    - Add CreateComponentButton to any view
    - Specify type and parentPath
    - Handle onCreated callback
 
 2. Toolbar Integration:
    - Use .componentCreationToolbar() modifier
    - Specify available types
    - Choose toolbar placement
 
 3. Menu Integration:
    - Use CreateComponentMenu for multiple options
    - Great for context menus and toolbar items
 
 4. Empty State Integration:
    - Show creation button when no components exist
    - Guide users to create their first component
 
 5. Inline Integration:
    - Add creation buttons within lists
    - Use swipe actions for contextual creation
 
 6. Programmatic Creation:
    - Access TemplateInstantiator.shared directly
    - Create components based on user actions
    - Batch create multiple components
 
 Example Usage in Your Module:
 
 ```swift
 struct MyModuleView: View {
     var body: some View {
         NavigationView {
             // Your content
         }
         .componentCreationToolbar(
             parentPath: "Modules/MyModule",
             types: [.feature, .component]
         ) { result in
             print("Created: \(result.name)")
             // Update your module's state
         }
     }
 }
 ```
 
 */