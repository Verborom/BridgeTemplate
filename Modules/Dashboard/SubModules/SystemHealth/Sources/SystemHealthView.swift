import SwiftUI

/// # System Health View
///
/// Orchestrates all system health monitoring features.
///
/// ## Overview
///
/// SystemHealthView is the main coordinator that brings together
/// various system monitoring features like CPU, Memory, and GPU metrics.
/// Each feature is independently versioned and hot-swappable.
///
/// ## Architecture
///
/// ```
/// SystemHealthView (orchestrator)
/// ├── CPUMetrics (feature)
/// ├── MemoryMetrics (feature)
/// └── GPUMetrics (feature)
/// ```
public struct SystemHealthView: View {
    @StateObject private var cpuFeature = CPUMetricsFeature()
    @StateObject private var memoryFeature = MemoryMetricsFeature()
    // Future: @StateObject private var gpuFeature = GPUMetricsFeature()
    
    public init() {}
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: "heart.circle")
                    .font(.title2)
                    .foregroundColor(.green)
                Text("System Health")
                    .font(.headline)
                Spacer()
                
                // Version info
                Text("v1.1.0")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 8)
            
            // Features
            VStack(spacing: 8) {
                // CPU Metrics Feature
                cpuFeature.view
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .scale.combined(with: .opacity)
                    ))
                
                Divider()
                
                // Memory Metrics Feature
                memoryFeature.view
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .scale.combined(with: .opacity)
                    ))
                
                // Future: GPU Metrics
                // gpuFeature.view
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

/// # Feature Protocol
///
/// Common protocol for all system health features.
protocol SystemHealthFeature: ObservableObject {
    associatedtype ContentView: View
    
    var id: String { get }
    var version: String { get }
    var view: ContentView { get }
    
    func refresh()
}

/// # CPU Metrics Feature
///
/// Monitors and displays CPU usage metrics.
class CPUMetricsFeature: SystemHealthFeature, ObservableObject {
    let id = "systemHealth.cpu"
    let version = "1.0.0"
    
    var view: some View {
        CPUMetricsView()
    }
    
    func refresh() {
        // Trigger refresh
    }
}

/// # Memory Metrics Feature
///
/// Monitors and displays memory usage metrics.
class MemoryMetricsFeature: SystemHealthFeature, ObservableObject {
    let id = "systemHealth.memory"
    let version = "1.0.0"
    
    var view: some View {
        MemoryMetricsView()
    }
    
    func refresh() {
        // Trigger refresh
    }
}

// Placeholder views - will be replaced by actual feature implementations
struct CPUMetricsView: View {
    var body: some View {
        Text("CPU Metrics (Loading...)")
            .foregroundColor(.secondary)
    }
}

struct MemoryMetricsView: View {
    var body: some View {
        Text("Memory Metrics (Loading...)")
            .foregroundColor(.secondary)
    }
}