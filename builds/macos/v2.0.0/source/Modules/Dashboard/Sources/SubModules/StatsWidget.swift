import SwiftUI

/// # StatsWidget Sub-Module
///
/// A hot-swappable widget displaying key project statistics with beautiful
/// animated cards. This sub-module can be updated independently without
/// affecting the parent Dashboard module.
///
/// ## Overview
///
/// StatsWidget is a perfect example of Bridge Template's infinite modularity.
/// As a sub-module of Dashboard, it can be versioned, updated, and hot-swapped
/// independently. This enables granular updates like changing the animation
/// style or adding new stat types without touching any other part of the system.
///
/// ## Topics
///
/// ### Main Components
/// - ``StatsWidget``
/// - ``StatCardView``
///
/// ### Animations
/// - ``StatCardAnimation``
/// - ``CountingAnimation``
///
/// ### Version History
/// - v1.2.1: Added gradient animations
/// - v1.2.0: Introduced counting animations
/// - v1.1.0: Added hover effects
/// - v1.0.0: Initial implementation
///
/// ## Usage
/// ```swift
/// // The StatsWidget is automatically loaded by Dashboard
/// // To update just this widget:
/// try await moduleManager.updateModule(
///     identifier: "com.bridge.dashboard.stats",
///     to: "1.2.1"
/// )
/// ```
@MainActor
public class StatsWidget: BridgeModule {
    
    /// Unique identifier for the stats widget sub-module
    public let id = "com.bridge.dashboard.stats"
    
    /// Display name for debugging and logs
    public let displayName = "Statistics Widget"
    
    /// Icon representing this widget
    public let icon = "chart.bar.xaxis"
    
    /// Current version of the widget
    public let version = ModuleVersion(major: 1, minor: 2, patch: 1)
    
    /// No sub-modules (widgets don't nest further in this example)
    public let subModules: [String: any BridgeModule] = [:]
    
    /// No dependencies - relies on parent Dashboard for data
    public let dependencies: [String] = []
    
    /// The widget's view
    public var view: AnyView {
        AnyView(
            Text("Stats Widget View")
                .padding()
        )
    }
    
    /// Initialize the widget
    public func initialize() async throws {
        print("📊 Initializing StatsWidget v\(version)")
    }
    
    /// Cleanup resources
    public func cleanup() async {
        print("📊 Cleaning up StatsWidget")
    }
    
    /// Always safe to unload
    public func canUnload() -> Bool {
        true
    }
    
    /// Handle messages from parent or system
    public func receiveMessage(_ message: ModuleMessage) async throws {
        switch message.type {
        case "updateAnimation":
            // Update animation style
            print("📊 Updating animation style")
        case "refreshStats":
            // Refresh statistics display
            print("📊 Refreshing statistics")
        default:
            print("📊 Unknown message: \(message.type)")
        }
    }
}

/// # StatCardView
///
/// Individual statistic card with gradient background and animations.
/// Supports hover effects and counting animations.
///
/// ## Topics
///
/// ### Properties
/// - ``stat``
/// - ``isAnimating``
///
/// ### Animations
/// - Hover scale effect
/// - Gradient shimmer
/// - Number counting
public struct StatCardView: View {
    
    /// The statistic to display
    let stat: DashboardStat
    
    /// Hover state for animations
    @State private var isHovered = false
    
    /// Animation state
    @State private var isAnimating = false
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Icon with gradient
            HStack {
                Image(systemName: stat.icon)
                    .font(.system(size: 24))
                    .foregroundStyle(stat.gradient)
                    .shadow(color: Color.black.opacity(0.1), radius: 4)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .animation(
                        .easeInOut(duration: 2).repeatForever(autoreverses: true),
                        value: isAnimating
                    )
                Spacer()
            }
            
            // Value with counting animation
            VStack(alignment: .leading, spacing: 4) {
                Text(stat.value)
                    .font(BridgeTypography.largeTitle)
                    .foregroundColor(.bridgeTextPrimary)
                    .contentTransition(.numericText())
                
                Text(stat.title)
                    .font(BridgeTypography.caption)
                    .foregroundColor(.bridgeTextSecondary)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassMorphism(cornerRadius: 16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(stat.gradient.opacity(0.2), lineWidth: 1)
        )
        .shadow(
            color: Color.black.opacity(isHovered ? 0.15 : 0.08),
            radius: isHovered ? 15 : 10,
            x: 0,
            y: isHovered ? 8 : 5
        )
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
        .onAppear {
            isAnimating = true
        }
    }
}