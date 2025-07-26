import SwiftUI

/// # Memory Metrics View
///
/// Main view for the memory metrics feature.
public struct MemoryMetricsView: View {
    @StateObject private var dataSource = MemoryDataSource()
    
    public init() {}
    
    public var body: some View {
        MemoryDisplayView(dataSource: dataSource)
    }
}

/// # Memory Data Source
class MemoryDataSource: ObservableObject {
    @Published var usage: Double = 0.0
    @Published var total: Double = 32.0 // GB
    @Published var used: Double = 0.0
    @Published var cached: Double = 0.0
    
    private var updateTimer: Timer?
    
    init() {
        startMonitoring()
    }
    
    func startMonitoring() {
        updateTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            self.updateMetrics()
        }
        updateMetrics()
    }
    
    private func updateMetrics() {
        used = Double.random(in: 8...24)
        usage = (used / total) * 100
        cached = Double.random(in: 2...6)
    }
}

/// # Memory Display View
struct MemoryDisplayView: View {
    @ObservedObject var dataSource: MemoryDataSource
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                Image(systemName: "memorychip")
                    .foregroundColor(.purple)
                Text("Memory")
                    .font(.headline)
                Spacer()
            }
            
            // Main display
            HStack(spacing: 16) {
                // Reuse PercentageBar from CPUMetrics
                PercentageBar(
                    value: dataSource.usage,
                    maxValue: 100,
                    barColor: dataSource.usage > 80 ? .red : .purple
                )
                .frame(width: 120)
                
                // Memory details
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(String(format: "%.1f", dataSource.used)) / \(Int(dataSource.total)) GB")
                        .font(.caption)
                        .fontWeight(.medium)
                    Text("Cached: \(String(format: "%.1f", dataSource.cached)) GB")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}