/// # NewBridgeMac Application
///
/// The new Bridge Template macOS application built with the architectural rebuild system.
/// This app demonstrates the revolutionary dynamic module loading, UniversalTemplate system,
/// and infinite nesting architecture.
///
/// ## Overview
///
/// NewBridgeMac represents the next generation of modular development with:
/// - Dynamic module discovery and loading
/// - Runtime component creation via UniversalTemplate
/// - Hot-swappable architecture with zero downtime
/// - Infinite nesting capabilities
/// - Professional git workflow integration
///
/// ## Architecture
///
/// The app uses the new ModuleManager with dynamic discovery to load all modules:
/// - PersonalAssistant (with 4 submodules)
/// - Projects (with 5 submodules)
/// - Documents (with 4 submodules)
/// - Settings (with 4 submodules)
/// - Terminal (real v1.3.0 implementation)
///
/// ## Topics
/// ### Core Components
/// - ``ContentView`` - Main application interface
/// - ``ModuleNavigationView`` - Dynamic module sidebar
/// - ``ModuleDetailView`` - Module content display
///
/// ## Version History
/// - v3.0.0: Initial architectural rebuild implementation
///
/// ## Usage
/// ```swift
/// @main
/// struct NewBridgeMacApp: App {
///     var body: some Scene {
///         WindowGroup {
///             ContentView()
///         }
///     }
/// }
/// ```
import SwiftUI
import BridgeCore

@main
struct NewBridgeMacApp: App {
    
    /// Shared module manager for the entire application
    @StateObject private var moduleManager = ModuleManager()
    
    /// App initialization and lifecycle
    init() {
        print("🌉 Starting NewBridgeMac with Architectural Rebuild System")
        print("📍 Version: 3.0.0 (Architectural Rebuild)")
        print("🏗️ Using dynamic module discovery and UniversalTemplate system")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(moduleManager)
                .frame(minWidth: 1000, minHeight: 700)
                .onAppear {
                    Task {
                        await initializeApp()
                    }
                }
        }
        .windowStyle(.automatic)
        .windowToolbarStyle(.unified)
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("About NewBridgeMac") {
                    // Show about dialog
                }
            }
        }
    }
    
    /// Initialize the application with dynamic module discovery
    private func initializeApp() async {
        print("🔍 Starting dynamic module discovery...")
        
        await moduleManager.discoverAndLoadModules()
        
        print("✅ Loaded \(moduleManager.loadedModules.count) modules:")
        for (id, module) in moduleManager.loadedModules {
            print("   📦 \(module.displayName) v\(module.version)")
        }
        
        print("🎉 NewBridgeMac initialization complete!")
        print("🌉 Architectural rebuild system operational")
    }
}