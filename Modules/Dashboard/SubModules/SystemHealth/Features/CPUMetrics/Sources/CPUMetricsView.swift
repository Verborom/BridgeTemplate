import SwiftUI

/// # CPU Metrics View
///
/// Main view for the CPU metrics feature.
///
/// ## Overview
///
/// This is the entry point for the CPU metrics feature, combining
/// the data source with the display components.
public struct CPUMetricsView: View {
    @StateObject private var dataSource = CPUDataSource()
    
    public init() {}
    
    public var body: some View {
        CPUDisplayView(dataSource: dataSource)
    }
}