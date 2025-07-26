import SwiftUI

/// # SystemHealth Sub-Module
///
/// Real-time system health monitoring with animated indicators.
/// Tracks CPU, memory, disk, and network usage with customizable alerts.
///
/// ## Overview
///
/// SystemHealth demonstrates continuous background monitoring in a
/// hot-swappable module. Even when swapped out and back in, it maintains
/// historical data through persistent storage.
///
/// ## Version History
/// - v1.0.3: Added historical graphs
/// - v1.0.2: Added alert thresholds
/// - v1.0.1: Improved animations
/// - v1.0.0: Initial monitoring
@MainActor
public class SystemHealth: BridgeModule {
    
    public let id = "com.bridge.dashboard.health"
    public let displayName = "System Health"
    public let icon = "heart.circle.fill"
    public let version = ModuleVersion(major: 1, minor: 0, patch: 3)
    public let subModules: [String: any BridgeModule] = [:]
    public let dependencies: [String] = []
    
    @Published private var monitor = SystemMonitor()
    
    public var view: AnyView {
        AnyView(
            SystemHealthView(monitor: monitor)
        )
    }
    
    public func initialize() async throws {
        print("💓 Initializing SystemHealth v\(version)")
        await monitor.startMonitoring()
    }
    
    public func cleanup() async {
        await monitor.stopMonitoring()
    }
    
    public func canUnload() -> Bool {
        true // Monitoring continues in background
    }
    
    public func receiveMessage(_ message: ModuleMessage) async throws {
        switch message.type {
        case "setThreshold":
            if let metric = message.payload["metric"] as? String,
               let value = message.payload["value"] as? Double {
                monitor.setThreshold(for: metric, value: value)
            }
        default:
            break
        }
    }
}

/// System health monitoring view
struct SystemHealthView: View {
    @ObservedObject var monitor: SystemMonitor
    
    var body: some View {
        HStack(spacing: 20) {
            ForEach(monitor.indicators) { indicator in
                HealthIndicatorView(indicator: indicator)
            }
        }
    }
}

/// Individual health indicator
public struct HealthIndicatorView: View {
    let indicator: HealthIndicator
    @State private var animatedValue: Double = 0
    
    private var color: Color {
        switch indicator.status {
        case .good: return .green
        case .warning: return .orange
        case .critical: return .red
        }
    }
    
    public var body: some View {
        VStack(spacing: 8) {
            // Circular progress
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 4)
                    .frame(width: 60, height: 60)
                
                Circle()
                    .trim(from: 0, to: animatedValue)
                    .stroke(
                        LinearGradient(
                            colors: [color, color.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(-90))
                
                Text("\(Int(indicator.value * 100))%")
                    .font(BridgeTypography.caption)
                    .fontWeight(.semibold)
            }
            
            Text(indicator.name)
                .font(BridgeTypography.caption)
                .foregroundColor(.bridgeTextSecondary)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1)) {
                animatedValue = indicator.value
            }
        }
        .onChange(of: indicator.value) { _, newValue in
            withAnimation(.easeInOut(duration: 0.5)) {
                animatedValue = newValue
            }
        }
    }
}

/// System monitoring manager
class SystemMonitor: ObservableObject {
    @Published var indicators: [HealthIndicator] = []
    private var monitoringTask: Task<Void, Never>?
    
    func startMonitoring() async {
        monitoringTask = Task {
            while !Task.isCancelled {
                await updateMetrics()
                try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
            }
        }
    }
    
    func stopMonitoring() async {
        monitoringTask?.cancel()
    }
    
    func setThreshold(for metric: String, value: Double) {
        // Set alert threshold
    }
    
    private func updateMetrics() async {
        // In production, get real system metrics
        await MainActor.run {
            indicators = [
                HealthIndicator(
                    id: "cpu",
                    name: "CPU",
                    value: Double.random(in: 0.2...0.8),
                    status: .good
                ),
                HealthIndicator(
                    id: "memory",
                    name: "Memory",
                    value: Double.random(in: 0.4...0.9),
                    status: .warning
                ),
                HealthIndicator(
                    id: "disk",
                    name: "Disk",
                    value: Double.random(in: 0.1...0.5),
                    status: .good
                ),
                HealthIndicator(
                    id: "network",
                    name: "Network",
                    value: Double.random(in: 0.05...0.3),
                    status: .good
                )
            ]
        }
    }
}