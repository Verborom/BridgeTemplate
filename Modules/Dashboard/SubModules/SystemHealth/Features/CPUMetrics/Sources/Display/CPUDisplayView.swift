import SwiftUI

/// # CPU Display View
///
/// Main display component for CPU metrics.
///
/// ## Overview
///
/// Orchestrates the various widgets that display CPU information,
/// including percentage bar, number display, and animations.
public struct CPUDisplayView: View {
    @ObservedObject var dataSource: CPUDataSource
    @State private var showDetails = false
    
    public init(dataSource: CPUDataSource) {
        self.dataSource = dataSource
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                Image(systemName: "cpu")
                    .foregroundColor(.blue)
                Text("CPU")
                    .font(.headline)
                Spacer()
                
                // Toggle details
                Button(action: { showDetails.toggle() }) {
                    Image(systemName: showDetails ? "chevron.up" : "chevron.down")
                        .font(.caption)
                }
                .buttonStyle(.plain)
            }
            
            // Main display
            HStack(spacing: 16) {
                // Percentage bar widget
                PercentageBar(
                    value: dataSource.usage,
                    maxValue: 100,
                    barColor: colorForUsage(dataSource.usage)
                )
                .frame(width: 120)
                
                // Number display widget
                NumberDisplay(
                    value: dataSource.usage,
                    unit: "%",
                    precision: 0
                )
            }
            
            // Animation widget
            CPUAnimation(isActive: dataSource.usage > 50)
                .frame(height: 4)
            
            // Details (collapsible)
            if showDetails {
                VStack(alignment: .leading, spacing: 4) {
                    DetailRow(label: "Cores", value: "\(dataSource.cores)")
                    DetailRow(label: "Threads", value: "\(dataSource.threads)")
                    DetailRow(label: "Frequency", value: String(format: "%.1f GHz", dataSource.frequency))
                    DetailRow(label: "Temperature", value: String(format: "%.0f°C", dataSource.temperature))
                }
                .font(.caption)
                .transition(.asymmetric(
                    insertion: .push(from: .top).combined(with: .opacity),
                    removal: .push(from: .bottom).combined(with: .opacity)
                ))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showDetails)
    }
    
    private func colorForUsage(_ usage: Double) -> Color {
        switch usage {
        case 0..<50:
            return .green
        case 50..<80:
            return .orange
        default:
            return .red
        }
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text("\(label):")
                .foregroundColor(.secondary)
            Text(value)
                .fontWeight(.medium)
        }
    }
}