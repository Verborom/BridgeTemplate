import Foundation
import Combine

/// # CPU Data Source
///
/// Provides real-time CPU usage data for the CPU metrics feature.
///
/// ## Overview
///
/// This component handles the data collection and processing for CPU metrics.
/// In production, this would interface with system APIs to get actual CPU usage.
public class CPUDataSource: ObservableObject {
    @Published public var usage: Double = 0.0
    @Published public var cores: Int = 8
    @Published public var threads: Int = 16
    @Published public var temperature: Double = 45.0
    @Published public var frequency: Double = 2.4 // GHz
    
    private var updateTimer: Timer?
    
    public init() {
        startMonitoring()
    }
    
    /// Start monitoring CPU metrics
    public func startMonitoring() {
        updateTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            self.updateMetrics()
        }
    }
    
    /// Stop monitoring
    public func stopMonitoring() {
        updateTimer?.invalidate()
        updateTimer = nil
    }
    
    /// Update CPU metrics with mock data
    private func updateMetrics() {
        // In production, would use actual system APIs
        usage = Double.random(in: 10...90)
        temperature = Double.random(in: 40...75)
        frequency = Double.random(in: 1.8...3.2)
    }
    
    deinit {
        stopMonitoring()
    }
}