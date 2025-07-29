import SwiftUI
import Terminal

/// # BridgeMac Application
///
/// The main macOS application that hosts the modular Bridge Template system.
/// This is a thin shell that loads and manages modules dynamically.
///
/// ## Overview
///
/// BridgeMac demonstrates the power of the modular architecture. The application
/// itself is minimal - it simply provides the window chrome and module hosting.
/// All functionality comes from hot-swappable modules that can be updated
/// without rebuilding or restarting the application.
///
/// ## Architecture
///
/// ```
/// BridgeMac (Shell)
/// ├── ModuleManager (Core)
/// ├── NavigationSplitView (UI)
/// └── Loaded Modules
///     ├── Dashboard
///     ├── Projects
///     ├── Terminal
///     └── ... (infinite nesting)
/// ```
///
/// ## Version
/// - v2.0.0: Complete rewrite for modular architecture
/// - v1.0.1: Arc Browser design enhancement
/// - v1.0.0: Initial foundation
@main
struct BridgeMacApp: App {
    
    /// Module manager instance
    @StateObject private var moduleManager = ModuleManager()
    
    /// Application model
    @StateObject private var appModel = AppModel()
    
    /// Version manager
    private let versionManager = VersionManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(moduleManager)
                .environmentObject(appModel)
                .frame(minWidth: 1200, minHeight: 800)
                .background(Color.bridgeBackground)
                .onAppear {
                    Task {
                        await loadDefaultModules()
                    }
                }
                .sheet(isPresented: $appModel.showModulePicker) {
                    ModuleSelectorView()
                        .environmentObject(moduleManager)
                        .environmentObject(appModel)
                }
        }
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified(showsTitle: false))
        .commands {
            ModuleCommands()
        }
        
        Settings {
            SettingsView()
                .environmentObject(moduleManager)
                .environmentObject(appModel)
                .frame(width: 600, height: 500)
        }
    }
    
    /// Load default modules on startup
    private func loadDefaultModules() async {
        do {
            // First ensure modules are discovered
            await moduleManager.discoverAndLoadModules()
            
            // Load core modules with real implementations
            _ = try await moduleManager.loadModule(identifier: "com.bridge.dashboard")
            _ = try await moduleManager.loadModule(identifier: "com.bridge.projects")
            
            // Load Terminal module
            _ = try await moduleManager.loadModule(identifier: "com.bridge.terminal")
            
            // Set default selection to Dashboard
            appModel.selectedModuleId = "com.bridge.dashboard"
        } catch {
            print("❌ Failed to load default modules: \(error)")
        }
    }
}

/// # Main Content View
///
/// The primary interface showing module navigation and content.
struct ContentView: View {
    @EnvironmentObject var moduleManager: ModuleManager
    @EnvironmentObject var appModel: AppModel
    
    var body: some View {
        NavigationSplitView {
            ModuleSidebar()
                .navigationSplitViewColumnWidth(min: 250, ideal: 300, max: 350)
        } detail: {
            ModuleContentArea()
        }
        .navigationSplitViewStyle(.balanced)
    }
}

/// # Module Sidebar
///
/// Displays loaded modules with hot-swap controls.
struct ModuleSidebar: View {
    @EnvironmentObject var moduleManager: ModuleManager
    @EnvironmentObject var appModel: AppModel
    @State private var hoveredModuleId: String?
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 8) {
                Image(systemName: "bridge")
                    .font(.system(size: 40))
                    .foregroundStyle(LinearGradient.arcPrimary)
                    .shadow(color: Color.bridgePrimary.opacity(0.3), radius: 10)
                
                Text("Bridge Template v3.0")
                    .font(BridgeTypography.title2)
                    .foregroundColor(.bridgeTextPrimary)
                
                Text("\(moduleManager.loadedModules.count) modules loaded")
                    .font(BridgeTypography.caption)
                    .foregroundColor(.bridgeTextSecondary)
            }
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity)
            .background(LinearGradient.sidebarGradient.opacity(0.3))
            
            // System Status Tile
            SystemStatusTile()
                .padding(.horizontal, 12)
                .padding(.bottom, 8)
            
            // Module List
            ScrollView {
                VStack(spacing: 4) {
                    ForEach(Array(moduleManager.loadedModules.values), id: \.id) { module in
                        ModuleRow(
                            module: module,
                            isSelected: appModel.selectedModuleId == module.id,
                            isHovered: hoveredModuleId == module.id,
                            onTap: {
                                appModel.selectedModuleId = module.id
                            },
                            onHotSwap: {
                                Task {
                                    await hotSwapModule(module)
                                }
                            }
                        )
                        .onHover { hovering in
                            hoveredModuleId = hovering ? module.id : nil
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            }
            
            Spacer()
            
            // Add Module Button
            Button(action: { appModel.showModulePicker = true }) {
                Label("Add Module", systemImage: "plus.circle.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            ZStack {
                LinearGradient.sidebarGradient
                VisualEffectBlur(material: .sidebar)
                    .opacity(0.5)
            }
        )
    }
    
    /// Hot-swap a module to a different version
    private func hotSwapModule(_ module: any BridgeModule) async {
        // In production, show version picker
        // For demo, swap to a different version
        do {
            let newVersion = "1.6.0" // Example
            _ = try await moduleManager.updateModule(
                identifier: module.id,
                to: newVersion
            )
        } catch {
            print("❌ Hot-swap failed: \(error)")
        }
    }
}

/// # Module Row
///
/// Individual module in the sidebar with version and controls.
struct ModuleRow: View {
    let module: any BridgeModule
    let isSelected: Bool
    let isHovered: Bool
    let onTap: () -> Void
    let onHotSwap: () -> Void
    
    private var gradient: LinearGradient {
        // Return gradient based on module type
        switch module.id {
        case "com.bridge.dashboard": return .dashboardGradient
        case "com.bridge.projects": return .projectsGradient
        case "com.bridge.terminal": return .terminalGradient
        default: return .arcPrimary
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: module.icon)
                .font(.system(size: 18))
                .foregroundColor(isSelected ? .white : Color.bridgeTextPrimary)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(module.displayName)
                    .font(BridgeTypography.headline)
                    .foregroundColor(isSelected ? .white : .bridgeTextPrimary)
                
                Text("v\(module.version)")
                    .font(BridgeTypography.caption)
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .bridgeTextSecondary)
            }
            
            Spacer()
            
            // Terminal status indicators
            if module.id == "com.bridge.terminal" {
                // Show terminal capabilities regardless of implementation
                VStack(alignment: .trailing, spacing: 2) {
                    // Terminal status indicator
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 4, height: 4)
                        Text("Terminal")
                            .font(.system(size: 9))
                            .foregroundColor(.green)
                    }
                    
                    // Claude integration indicator  
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 4, height: 4)
                        Text("Claude")
                            .font(.system(size: 9))
                            .foregroundColor(.blue)
                    }
                    
                    // Auto-permission indicator
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.purple)
                            .frame(width: 4, height: 4)
                        Text("Auto")
                            .font(.system(size: 9))
                            .foregroundColor(.purple)
                    }
                }
            }
            
            // Hot-swap button
            if isHovered && !isSelected {
                Button(action: onHotSwap) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 14))
                        .foregroundColor(.bridgeTextSecondary)
                }
                .buttonStyle(.plain)
                .help("Hot-swap module")
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            ZStack {
                if isSelected {
                    gradient
                        .cornerRadius(8)
                        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                } else if isHovered {
                    Color.white.opacity(0.1)
                        .cornerRadius(8)
                }
            }
        )
        .animation(.easeInOut(duration: 0.2), value: isSelected)
        .animation(.easeInOut(duration: 0.15), value: isHovered)
        .onTapGesture(perform: onTap)
    }
}

/// # Module Content Area
///
/// Displays the selected module's view.
struct ModuleContentArea: View {
    @EnvironmentObject var moduleManager: ModuleManager
    @EnvironmentObject var appModel: AppModel
    
    var body: some View {
        if let moduleId = appModel.selectedModuleId,
           let module = moduleManager.loadedModules[moduleId] {
            module.view
                .id(moduleId) // Force refresh on module change
                .transition(.opacity)
        } else {
            EmptyModuleView()
        }
    }
}

/// # Empty Module View
///
/// Shown when no module is selected.
struct EmptyModuleView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "square.grid.3x3.square")
                .font(.system(size: 80))
                .foregroundStyle(LinearGradient.arcPrimary)
                .opacity(0.5)
            
            Text("Select a module to begin")
                .font(BridgeTypography.title)
                .foregroundColor(.bridgeTextSecondary)
            
            Text("Or add a new module using the + button")
                .font(BridgeTypography.body)
                .foregroundColor(.bridgeTextSecondary)
                .opacity(0.7)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(LinearGradient.subtleBackground)
    }
}

/// # Module Commands
///
/// Menu bar commands for module operations.
struct ModuleCommands: Commands {
    var body: some Commands {
        CommandMenu("Modules") {
            Button("Reload Current Module") {
                // Implementation
            }
            .keyboardShortcut("R", modifiers: [.command, .shift])
            
            Button("Hot-Swap Module...") {
                // Implementation
            }
            .keyboardShortcut("H", modifiers: [.command, .shift])
            
            Divider()
            
            Button("Load Module...") {
                // Implementation
            }
            .keyboardShortcut("L", modifiers: [.command])
            
            Button("Unload Module") {
                // Implementation
            }
            .keyboardShortcut("U", modifiers: [.command])
        }
    }
}

/// # App Model
///
/// Application-level state management.
@MainActor
class AppModel: ObservableObject {
    @Published var selectedModuleId: String?
    @Published var showModulePicker = false
    @Published var isLoading = false
}

/// # Settings View
///
/// Application preferences and module management.
struct SettingsView: View {
    @EnvironmentObject var moduleManager: ModuleManager
    
    var body: some View {
        TabView {
            GeneralSettings()
                .tabItem {
                    Label("General", systemImage: "gear")
                }
            
            ModuleSettings()
                .tabItem {
                    Label("Modules", systemImage: "square.grid.3x3")
                }
                .environmentObject(moduleManager)
            
            DeveloperSettings()
                .tabItem {
                    Label("Developer", systemImage: "hammer")
                }
        }
        .padding(20)
    }
}

struct GeneralSettings: View {
    var body: some View {
        Text("General Settings")
    }
}

struct ModuleSettings: View {
    @EnvironmentObject var moduleManager: ModuleManager
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Loaded Modules")
                .font(BridgeTypography.title2)
            
            List(Array(moduleManager.loadedModules.values), id: \.id) { module in
                HStack {
                    VStack(alignment: .leading) {
                        Text(module.displayName)
                            .font(BridgeTypography.headline)
                        Text("\(module.id) • v\(module.version)")
                            .font(BridgeTypography.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Text("\(module.subModules.count) sub-modules")
                        .font(BridgeTypography.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            }
        }
    }
}

struct DeveloperSettings: View {
    var body: some View {
        Text("Developer Settings")
    }
}

/// # Module Selector View
///
/// Dialog for selecting and loading available modules.
struct ModuleSelectorView: View {
    @EnvironmentObject var moduleManager: ModuleManager
    @EnvironmentObject var appModel: AppModel
    @Environment(\.dismiss) var dismiss
    @State private var selectedModuleId: String?
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading) {
                    Text("Add Module")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("Select a module to load into the system")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle(.plain)
            }
            .padding()
            .background(Color(NSColor.windowBackgroundColor))
            
            Divider()
            
            // Module List
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(moduleManager.availableModules, id: \.identifier) { metadata in
                        ModuleOptionRow(
                            metadata: metadata,
                            isLoaded: moduleManager.isModuleLoaded(metadata.identifier),
                            isSelected: selectedModuleId == metadata.identifier,
                            onSelect: {
                                if !moduleManager.isModuleLoaded(metadata.identifier) {
                                    selectedModuleId = metadata.identifier
                                }
                            }
                        )
                    }
                }
                .padding()
            }
            
            Divider()
            
            // Action Buttons
            HStack {
                Spacer()
                
                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle(.plain)
                
                Button("Load Module") {
                    if let moduleId = selectedModuleId {
                        Task {
                            isLoading = true
                            do {
                                _ = try await moduleManager.loadModule(identifier: moduleId)
                                appModel.selectedModuleId = moduleId
                                dismiss()
                            } catch {
                                print("Failed to load module: \(error)")
                            }
                            isLoading = false
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(selectedModuleId == nil || isLoading)
            }
            .padding()
        }
        .frame(width: 500, height: 400)
    }
}

struct ModuleOptionRow: View {
    let metadata: ModuleMetadata
    let isLoaded: Bool
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "cube.box.fill")
                .font(.title2)
                .foregroundColor(isLoaded ? .gray : .blue)
            
            VStack(alignment: .leading) {
                Text(metadata.name)
                    .font(.headline)
                    .foregroundColor(isLoaded ? .secondary : .primary)
                
                Text(metadata.identifier)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if isLoaded {
                Text("Loaded")
                    .font(.caption)
                    .foregroundColor(.green)
            } else {
                Text("v\(metadata.versions.last ?? "1.0.0")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected ? Color.accentColor.opacity(0.2) : Color(NSColor.controlBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
        )
        .opacity(isLoaded ? 0.6 : 1.0)
        .allowsHitTesting(!isLoaded)
        .onTapGesture(perform: onSelect)
    }
}

// MARK: - Design System Extensions

/// Bridge Template color palette
extension Color {
    static let bridgeBackground = Color(NSColor.windowBackgroundColor)
    static let bridgeTextPrimary = Color(NSColor.labelColor)
    static let bridgeTextSecondary = Color(NSColor.secondaryLabelColor)
    static let bridgePrimary = Color.blue
}

/// Bridge Template typography
struct BridgeTypography {
    static let largeTitle = Font.system(size: 28, weight: .bold, design: .default)
    static let title = Font.system(size: 24, weight: .semibold, design: .default)
    static let title2 = Font.system(size: 20, weight: .semibold, design: .default)
    static let headline = Font.system(size: 16, weight: .medium, design: .default)
    static let body = Font.system(size: 14, weight: .regular, design: .default)
    static let caption = Font.system(size: 11, weight: .regular, design: .default)
}

/// Visual effect blur for macOS
struct VisualEffectBlur: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = .behindWindow
        view.state = .active
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
    }
}

/// Bridge Template gradients
extension LinearGradient {
    static let arcPrimary = LinearGradient(
        colors: [Color.blue, Color.purple],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let dashboardGradient = LinearGradient(
        colors: [Color.blue, Color.cyan],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let projectsGradient = LinearGradient(
        colors: [Color.purple, Color.pink],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let terminalGradient = LinearGradient(
        colors: [Color.green, Color.blue, Color.purple],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let subtleBackground = LinearGradient(
        colors: [Color.gray.opacity(0.05), Color.gray.opacity(0.02)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let sidebarGradient = LinearGradient(
        colors: [Color.black.opacity(0.9), Color.gray.opacity(0.1)],
        startPoint: .top,
        endPoint: .bottom
    )
}