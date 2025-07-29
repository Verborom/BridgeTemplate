/// # WelcomeView
///
/// Application overview that showcases the architectural rebuild achievements
/// and provides navigation to key features.
///
/// ## Overview
///
/// The welcome screen demonstrates:
/// - Revolutionary architectural improvements
/// - Performance metrics and capabilities
/// - Module overview and statistics
/// - Quick access to key functionality
import SwiftUI
import BridgeCore

struct WelcomeView: View {
    @EnvironmentObject var moduleManager: ModuleManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Header
                welcomeHeader
                
                // Architecture highlights
                architectureHighlights
                
                // Module overview
                moduleOverview
                
                // Performance metrics
                performanceMetrics
                
                Spacer()
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial)
    }
    
    /// Welcome header
    private var welcomeHeader: some View {
        VStack(spacing: 16) {
            Image(systemName: "sparkles")
                .font(.system(size: 64))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.purple, .blue, .cyan],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text("NewBridgeMac v3.0.0")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Architectural Rebuild System")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Text("Revolutionary modular development with infinite nesting and hot-swapping capabilities")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .frame(maxWidth: 600)
        }
    }
    
    /// Architecture highlights
    private var architectureHighlights: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Architectural Achievements")
                .font(.headline)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                FeatureCard(
                    icon: "gear.badge",
                    title: "Dynamic Module Discovery",
                    description: "No hardcoded modules - everything discovered at runtime"
                )
                
                FeatureCard(
                    icon: "doc.badge.plus",
                    title: "UniversalTemplate System",
                    description: "Generate components at any hierarchy level instantly"
                )
                
                FeatureCard(
                    icon: "arrow.triangle.2.circlepath",
                    title: "Hot-Swapping",
                    description: "Update modules without restart or data loss"
                )
                
                FeatureCard(
                    icon: "infinity",
                    title: "Infinite Nesting",
                    description: "Components within components at unlimited depth"
                )
            }
        }
    }
    
    /// Module overview
    private var moduleOverview: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Loaded Modules")
                .font(.headline)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                ForEach(Array(moduleManager.loadedModules.values), id: \.id) { module in
                    ModuleCard(module: module)
                }
            }
        }
    }
    
    /// Performance metrics
    private var performanceMetrics: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Performance Metrics")
                .font(.headline)
            
            HStack(spacing: 20) {
                MetricCard(
                    value: "\(moduleManager.loadedModules.count)",
                    label: "Active Modules",
                    color: .green
                )
                
                MetricCard(
                    value: "15s-3min",
                    label: "Build Times",
                    color: .blue
                )
                
                MetricCard(
                    value: "Zero",
                    label: "Downtime Updates",
                    color: .purple
                )
                
                MetricCard(
                    value: "∞",
                    label: "Nesting Depth",
                    color: .orange
                )
            }
        }
    }
}

/// Feature card for architecture highlights
struct FeatureCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.accentColor)
            
            Text(title)
                .font(.headline)
            
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.regularMaterial)
        .cornerRadius(12)
    }
}

/// Module card for overview
struct ModuleCard: View {
    let module: any BridgeModule
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: module.icon)
                .font(.title2)
                .foregroundColor(.accentColor)
            
            Text(module.displayName)
                .font(.caption)
                .fontWeight(.medium)
            
            Text("v\(module.version)")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.regularMaterial)
        .cornerRadius(8)
    }
}

/// Metric card for performance display
struct MetricCard: View {
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.regularMaterial)
        .cornerRadius(8)
    }
}