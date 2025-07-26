import SwiftUI

/// # System Status Tile
/// 
/// Displays real-time system information in the sidebar.
///
/// ## Overview
///
/// The System Status Tile provides at-a-glance system performance metrics
/// including CPU and memory usage, updated every 5 seconds.
///
/// ## Topics
///
/// ### Views
/// - ``SystemStatusTile``
///
/// ### State
/// - ``cpuUsage``
/// - ``memoryUsage``
/// - ``lastUpdated``
struct SystemStatusTile: View {
    @State private var cpuUsage: Double = 0.0
    @State private var memoryUsage: Double = 0.0
    @State private var lastUpdated = Date()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                Image(systemName: "cpu")
                    .foregroundColor(.blue)
                    .font(.system(size: 16))
                Text("System Status")
                    .font(.headline)
                Spacer()
            }
            
            // Metrics
            VStack(alignment: .leading, spacing: 4) {
                // CPU Usage
                HStack {
                    Text("CPU:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(Int(cpuUsage))%")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(cpuUsage > 80 ? .red : .primary)
                }
                
                // Memory Usage
                HStack {
                    Text("Memory:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(Int(memoryUsage))%")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(memoryUsage > 80 ? .red : .primary)
                }
                
                // Last Updated
                Text("Updated: \(lastUpdated.formatted(date: .omitted, time: .shortened))")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(12)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
        .onAppear {
            updateSystemStats()
            // Update every 5 seconds
            Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
                updateSystemStats()
            }
        }
    }
    
    /// Update system statistics with mock data
    ///
    /// In a production implementation, this would interface with
    /// actual system monitoring APIs.
    private func updateSystemStats() {
        // Simple mock data - real implementation would use system APIs
        withAnimation(.easeInOut(duration: 0.3)) {
            cpuUsage = Double.random(in: 10...90)
            memoryUsage = Double.random(in: 20...80)
            lastUpdated = Date()
        }
    }
}