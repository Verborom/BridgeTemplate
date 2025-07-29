/// # ContentView
///
/// The main application interface that showcases the architectural rebuild system.
/// Provides navigation between dynamically loaded modules with professional UI.
///
/// ## Overview
///
/// ContentView demonstrates the new architecture with:
/// - Dynamic module sidebar with real-time loading status
/// - Module detail views showing UniversalTemplate-generated content
/// - Seamless navigation between all hierarchy levels
/// - Status indicators showing module versions and health
///
/// ## Topics
/// ### Main Components
/// - ``ModuleNavigationView`` - Dynamic sidebar
/// - ``ModuleDetailView`` - Content display
/// - ``WelcomeView`` - Application overview
///
/// ## Version History
/// - v3.0.0: Initial implementation with dynamic architecture
import SwiftUI
import BridgeCore

struct ContentView: View {
    @EnvironmentObject var moduleManager: ModuleManager
    @State private var selectedModuleId: String? = nil
    @State private var showingAbout = false
    
    var body: some View {
        let _ = print("🔍 ContentView rendering with \(moduleManager.loadedModules.count) loaded modules")
        NavigationSplitView {
            // Dynamic module sidebar
            ModuleNavigationView(
                selectedModuleId: $selectedModuleId,
                modules: moduleManager.loadedModules
            )
        } detail: {
            // Main content area
            if let selectedId = selectedModuleId,
               let selectedModule = moduleManager.loadedModules[selectedId] {
                ModuleDetailView(module: selectedModule)
            } else {
                WelcomeView()
            }
        }
        .navigationTitle("NewBridgeMac v3.0.0")
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                // Module status indicator
                moduleStatusIndicator
                
                // Refresh modules button
                Button(action: refreshModules) {
                    Image(systemName: "arrow.clockwise")
                }
                .help("Refresh modules")
                
                // About button
                Button(action: { showingAbout = true }) {
                    Image(systemName: "info.circle")
                }
                .help("About NewBridgeMac")
            }
        }
        .sheet(isPresented: $showingAbout) {
            AboutView()
        }
    }
    
    /// Module status indicator showing loading state
    private var moduleStatusIndicator: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(moduleManager.loadedModules.isEmpty ? .orange : .green)
                .frame(width: 8, height: 8)
            
            Text("\(moduleManager.loadedModules.count)/\(moduleManager.availableModules.count)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .help("Loaded modules: \(moduleManager.loadedModules.count)")
    }
    
    /// Refresh all modules
    private func refreshModules() {
        Task {
            await moduleManager.discoverAndLoadModules()
        }
    }
}