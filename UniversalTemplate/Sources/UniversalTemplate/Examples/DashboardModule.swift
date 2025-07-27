import SwiftUI

/// # Example: Dashboard Module
///
/// This example demonstrates how to create a complete Module using UniversalTemplate.
/// The same pattern works for ANY hierarchy level - just change the hierarchyLevel property.
///
/// ## Overview
///
/// This Dashboard module showcases:
/// - Custom view creation
/// - Child component management
/// - Message handling
/// - State management
/// - CICD integration
@MainActor
public class DashboardModule: BaseComponent {
    
    // MARK: - Properties
    
    /// Dashboard-specific state
    @Published private var dashboardData = DashboardData()
    
    /// Refresh timer
    private var refreshTimer: Timer?
    
    // MARK: - Initialization
    
    public override init() {
        super.init()
        
        // Configure component identity
        self.name = "Dashboard"
        self.hierarchyLevel = .module
        self.version = ComponentVersion(2, 1, 0)
        self.icon = "square.grid.2x2"
        self.description = "Main dashboard module providing system overview and quick actions"
        
        // Define capabilities
        self.capabilities = [
            ComponentCapability(
                id: "real-time-updates",
                name: "Real-time Updates",
                description: "Provides live data updates every 5 seconds"
            ),
            ComponentCapability(
                id: "widget-hosting",
                name: "Widget Hosting",
                description: "Can host multiple dashboard widgets"
            ),
            ComponentCapability(
                id: "data-aggregation",
                name: "Data Aggregation",
                description: "Aggregates data from child components"
            )
        ]
        
        // Set default configuration
        self.configuration.features = ["auto-refresh", "dark-mode", "compact-view"]
        self.configuration.settings = [
            "refreshInterval": AnyCodable(5.0),
            "maxWidgets": AnyCodable(12),
            "defaultLayout": AnyCodable("grid")
        ]
    }
    
    // MARK: - View Creation
    
    public override func createView() -> AnyView {
        AnyView(
            DashboardView(module: self, data: dashboardData)
        )
    }
    
    // MARK: - Lifecycle Implementation
    
    public override func performInitialization() async throws {
        print("🚀 Initializing Dashboard Module v\(version)")
        
        // Create default widgets
        let widgets = try await createDefaultWidgets()
        
        // Add widgets as children
        for widget in widgets {
            children.append(widget)
            widget.parent = self
            try await widget.initialize()
        }
        
        // Start auto-refresh if enabled
        if configuration.features.contains("auto-refresh") {
            startAutoRefresh()
        }
        
        // Load saved dashboard state
        await loadDashboardState()
    }
    
    public override func performExecution() async throws -> ComponentResult {
        let startTime = Date()
        
        // Refresh all data
        try await refreshDashboardData()
        
        // Execute all child widgets
        var widgetResults: [String: Any] = [:]
        for child in children {
            let result = try await child.execute()
            widgetResults[child.name] = result.output?.value ?? "No data"
        }
        
        // Aggregate results
        let aggregatedData = aggregateWidgetData(widgetResults)
        
        let duration = Date().timeIntervalSince(startTime)
        
        return ComponentResult(
            success: true,
            output: AnyCodable(aggregatedData),
            duration: duration,
            metrics: [
                "widgetCount": Double(children.count),
                "dataPoints": Double(aggregatedData.count),
                "refreshTime": duration
            ]
        )
    }
    
    public override func performSuspension() async throws {
        // Stop auto-refresh
        refreshTimer?.invalidate()
        refreshTimer = nil
        
        // Save current state
        await saveDashboardState()
    }
    
    public override func performResumption() async throws {
        // Restart auto-refresh
        if configuration.features.contains("auto-refresh") {
            startAutoRefresh()
        }
        
        // Refresh data
        try await refreshDashboardData()
    }
    
    public override func performCleanup() async throws {
        // Stop timers
        refreshTimer?.invalidate()
        
        // Clear data
        dashboardData = DashboardData()
    }
    
    // MARK: - Message Handling
    
    public override func handleCustomMessage(_ message: ComponentMessage) async throws {
        switch message.type {
        case .command:
            try await handleCommand(message)
        case .event:
            handleEvent(message)
        default:
            break
        }
    }
    
    private func handleCommand(_ message: ComponentMessage) async throws {
        guard let command = message.payload["command"]?.value as? String else { return }
        
        switch command {
        case "refresh":
            _ = try await performExecution()
            
        case "add-widget":
            if let widgetType = message.payload["type"]?.value as? String {
                let widget = try await createWidget(type: widgetType)
                children.append(widget)
                widget.parent = self
                try await widget.initialize()
            }
            
        case "remove-widget":
            if let widgetId = message.payload["widgetId"]?.value as? String,
               let widgetUUID = UUID(uuidString: widgetId) {
                children.removeAll { $0.id == widgetUUID }
            }
            
        case "change-layout":
            if let layout = message.payload["layout"]?.value as? String {
                configuration.settings["defaultLayout"] = AnyCodable(layout)
            }
            
        default:
            print("Unknown command: \(command)")
        }
    }
    
    private func handleEvent(_ message: ComponentMessage) {
        guard let event = message.payload["event"]?.value as? String else { return }
        
        switch event {
        case "widget-data-updated":
            // Aggregate data from widgets
            Task {
                try? await refreshDashboardData()
            }
            
        default:
            print("Unhandled event: \(event)")
        }
    }
    
    // MARK: - Testing
    
    public override func performTests() async throws -> TestResult {
        var failures: [TestResult.TestFailure] = []
        
        // Test 1: Widget creation
        do {
            let testWidget = try await createWidget(type: "stats")
            if testWidget.hierarchyLevel != .widget {
                failures.append(TestResult.TestFailure(
                    test: "Widget Creation",
                    reason: "Widget has incorrect hierarchy level",
                    file: #file,
                    line: #line
                ))
            }
        } catch {
            failures.append(TestResult.TestFailure(
                test: "Widget Creation",
                reason: error.localizedDescription,
                file: #file,
                line: #line
            ))
        }
        
        // Test 2: Data refresh
        do {
            try await refreshDashboardData()
        } catch {
            failures.append(TestResult.TestFailure(
                test: "Data Refresh",
                reason: error.localizedDescription,
                file: #file,
                line: #line
            ))
        }
        
        // Test 3: Message handling
        let testMessage = ComponentMessage(
            source: id,
            type: .command,
            payload: ["command": AnyCodable("refresh")]
        )
        
        do {
            try await handleCustomMessage(testMessage)
        } catch {
            failures.append(TestResult.TestFailure(
                test: "Message Handling",
                reason: error.localizedDescription,
                file: #file,
                line: #line
            ))
        }
        
        return TestResult(
            passed: 3 - failures.count,
            failed: failures.count,
            skipped: 0,
            duration: 0.1,
            coverage: 0.75,
            failures: failures
        )
    }
    
    // MARK: - Private Methods
    
    private func createDefaultWidgets() async throws -> [any UniversalComponent] {
        var widgets: [any UniversalComponent] = []
        
        // Create stats widget
        widgets.append(StatsWidget())
        
        // Create activity widget
        widgets.append(ActivityWidget())
        
        // Create quick actions widget
        widgets.append(QuickActionsWidget())
        
        return widgets
    }
    
    private func createWidget(type: String) async throws -> any UniversalComponent {
        switch type {
        case "stats":
            return StatsWidget()
        case "activity":
            return ActivityWidget()
        case "quick-actions":
            return QuickActionsWidget()
        default:
            throw ComponentError.creationFailed("Unknown widget type: \(type)")
        }
    }
    
    private func startAutoRefresh() {
        let interval = configuration.settings["refreshInterval"]?.value as? Double ?? 5.0
        
        refreshTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            Task {
                try? await self.refreshDashboardData()
            }
        }
    }
    
    private func refreshDashboardData() async throws {
        // Simulate data refresh
        dashboardData.lastRefresh = Date()
        dashboardData.activeUsers = Int.random(in: 100...500)
        dashboardData.systemLoad = Double.random(in: 0...100)
        dashboardData.errorCount = Int.random(in: 0...10)
    }
    
    private func aggregateWidgetData(_ widgetResults: [String: Any]) -> [String: Any] {
        var aggregated: [String: Any] = [:]
        
        // Aggregate logic here
        aggregated["totalWidgets"] = widgetResults.count
        aggregated["timestamp"] = Date()
        aggregated["summary"] = dashboardData
        
        return aggregated
    }
    
    private func loadDashboardState() async {
        // Load from persistent storage
        // Implementation depends on storage mechanism
    }
    
    private func saveDashboardState() async {
        // Save to persistent storage
        // Implementation depends on storage mechanism
    }
}

// MARK: - Supporting Types

/// Dashboard data model
private struct DashboardData {
    var lastRefresh = Date()
    var activeUsers = 0
    var systemLoad = 0.0
    var errorCount = 0
}

/// Dashboard view
private struct DashboardView: View {
    let module: DashboardModule
    @ObservedObject var data: DashboardData
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                DashboardHeader(module: module)
                
                // Widgets grid
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 20) {
                    ForEach(module.children, id: \.id) { child in
                        child.view
                            .frame(height: 200)
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(12)
                    }
                }
                .padding()
            }
        }
    }
}

/// Dashboard header
private struct DashboardHeader: View {
    let module: DashboardModule
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(module.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Version \(module.version.description)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Action buttons
            HStack {
                Button(action: { refreshDashboard() }) {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
                
                Button(action: { addWidget() }) {
                    Label("Add Widget", systemImage: "plus")
                }
            }
        }
        .padding()
    }
    
    private func refreshDashboard() {
        Task {
            _ = try? await module.execute()
        }
    }
    
    private func addWidget() {
        // Show widget picker
    }
}

// MARK: - Example Widget Components

/// Stats widget example
@MainActor
class StatsWidget: BaseComponent {
    override init() {
        super.init()
        self.name = "Statistics"
        self.hierarchyLevel = .widget
        self.version = ComponentVersion(1, 0, 0)
        self.icon = "chart.bar"
    }
    
    override func createView() -> AnyView {
        AnyView(
            VStack {
                Label("Statistics", systemImage: icon)
                    .font(.headline)
                Spacer()
                Text("Charts go here")
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding()
        )
    }
}

/// Activity widget example
@MainActor
class ActivityWidget: BaseComponent {
    override init() {
        super.init()
        self.name = "Recent Activity"
        self.hierarchyLevel = .widget
        self.version = ComponentVersion(1, 0, 0)
        self.icon = "clock"
    }
    
    override func createView() -> AnyView {
        AnyView(
            VStack {
                Label("Recent Activity", systemImage: icon)
                    .font(.headline)
                Spacer()
                Text("Activity feed here")
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding()
        )
    }
}

/// Quick actions widget example
@MainActor
class QuickActionsWidget: BaseComponent {
    override init() {
        super.init()
        self.name = "Quick Actions"
        self.hierarchyLevel = .widget
        self.version = ComponentVersion(1, 0, 0)
        self.icon = "bolt"
    }
    
    override func createView() -> AnyView {
        AnyView(
            VStack {
                Label("Quick Actions", systemImage: icon)
                    .font(.headline)
                Spacer()
                Text("Action buttons here")
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding()
        )
    }
}