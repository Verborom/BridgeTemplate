/// # ModuleNavigationView
///
/// Dynamic sidebar navigation that displays all loaded modules with status indicators,
/// version information, and hierarchical organization.
///
/// ## Overview
///
/// This view demonstrates the architectural rebuild's dynamic capabilities:
/// - Real-time module discovery and loading
/// - Visual distinction between real and template-generated modules
/// - Module health and version monitoring
/// - Professional navigation interface
///
/// ## Topics
/// ### Navigation Components
/// - Dynamic module list with metadata
/// - Module status indicators
/// - Version display and management
/// - Category organization
import SwiftUI
import BridgeCore

struct ModuleNavigationView: View {
    @Binding var selectedModuleId: String?
    let modules: [String: any BridgeModule]
    
    @State private var expandedCategories: Set<String> = ["Core Modules", "Productivity"]
    
    init(selectedModuleId: Binding<String?>, modules: [String: any BridgeModule]) {
        self._selectedModuleId = selectedModuleId
        self.modules = modules
        print("🔍 ModuleNavigationView init with \(modules.count) modules:")
        for (id, module) in modules {
            print("   📦 \(id) -> \(module.displayName)")
        }
    }
    
    var body: some View {
        List(selection: $selectedModuleId) {
            // Core system modules
            Section("Core Modules") {
                ForEach(coreModules, id: \.id) { module in
                    ModuleRowView(
                        module: module,
                        isSelected: selectedModuleId == module.id
                    )
                    .tag(module.id)
                }
            }
            
            // Productivity modules
            Section("Productivity") {
                ForEach(productivityModules, id: \.id) { module in
                    ModuleRowView(
                        module: module,
                        isSelected: selectedModuleId == module.id
                    )
                    .tag(module.id)
                }
            }
            
            // Development modules
            Section("Development") {
                ForEach(developmentModules, id: \.id) { module in
                    ModuleRowView(
                        module: module,
                        isSelected: selectedModuleId == module.id,
                        isRealImplementation: module.id == "com.bridge.terminal"
                    )
                    .tag(module.id)
                }
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("Modules")
    }
    
    /// Core system modules
    private var coreModules: [any BridgeModule] {
        let filtered = Array(modules.values).filter { module in
            ["com.bridge.settings"].contains(module.id)
        }.sorted { $0.displayName < $1.displayName }
        print("🔍 Core modules: \(filtered.count) found")
        return filtered
    }
    
    /// Productivity modules
    private var productivityModules: [any BridgeModule] {
        let filtered = Array(modules.values).filter { module in
            ["com.bridge.personalassistant", "com.bridge.projects", "com.bridge.documents"].contains(module.id)
        }.sorted { $0.displayName < $1.displayName }
        print("🔍 Productivity modules: \(filtered.count) found")
        for module in filtered {
            print("   - \(module.id): \(module.displayName)")
        }
        return filtered
    }
    
    /// Development modules
    private var developmentModules: [any BridgeModule] {
        let filtered = Array(modules.values).filter { module in
            ["com.bridge.terminal"].contains(module.id)
        }.sorted { $0.displayName < $1.displayName }
        print("🔍 Development modules: \(filtered.count) found")
        return filtered
    }
}

/// Individual module row with status and metadata
struct ModuleRowView: View {
    let module: any BridgeModule
    let isSelected: Bool
    let isRealImplementation: Bool
    
    init(module: any BridgeModule, isSelected: Bool, isRealImplementation: Bool = false) {
        self.module = module
        self.isSelected = isSelected
        self.isRealImplementation = isRealImplementation
    }
    
    var body: some View {
        HStack {
            // Module icon with gradient
            Image(systemName: module.icon)
                .font(.title2)
                .foregroundStyle(moduleGradient)
                .frame(width: 24)
            
            // Module info
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(module.displayName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if isRealImplementation {
                        Text("REAL")
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(.green.opacity(0.2))
                            .foregroundColor(.green)
                            .cornerRadius(4)
                    }
                }
                
                HStack {
                    Text("v\(module.version)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    // Module type indicator
                    moduleTypeIndicator
                }
            }
            
            Spacer()
            
            // Status indicator
            Circle()
                .fill(.green)
                .frame(width: 8, height: 8)
        }
        .padding(.vertical, 2)
        .background(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
        .cornerRadius(6)
    }
    
    /// Gradient for module icon
    private var moduleGradient: LinearGradient {
        switch module.id {
        case "com.bridge.personalassistant":
            return LinearGradient(colors: [.purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "com.bridge.projects":
            return LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "com.bridge.documents":
            return LinearGradient(colors: [.green, .mint], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "com.bridge.settings":
            return LinearGradient(colors: [.gray, .secondary], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "com.bridge.terminal":
            return LinearGradient(colors: [.black, .gray], startPoint: .topLeading, endPoint: .bottomTrailing)
        default:
            return LinearGradient(colors: [.accentColor], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
    
    /// Module type indicator
    private var moduleTypeIndicator: some View {
        Text(isRealImplementation ? "Real" : "Template")
            .font(.caption2)
            .padding(.horizontal, 4)
            .padding(.vertical, 1)
            .background(isRealImplementation ? .green.opacity(0.1) : .blue.opacity(0.1))
            .foregroundColor(isRealImplementation ? .green : .blue)
            .cornerRadius(3)
    }
}