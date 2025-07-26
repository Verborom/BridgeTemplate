import SwiftUI

/// # Dashboard Module
///
/// The Dashboard module provides real-time project statistics, activity monitoring,
/// and system health visualization. This module supports hot-swapping and independent
/// versioning within the Bridge Template ecosystem.
///
/// ## Overview
///
/// The Dashboard serves as the primary landing module for Bridge Template applications.
/// It displays key metrics about active projects, recent activity, system performance,
/// and provides quick access to frequently used features. All widgets within the
/// dashboard are independently loadable sub-modules, enabling granular updates without
/// affecting the entire dashboard.
///
/// ## Topics
///
/// ### Main Components
/// - ``DashboardModule``
/// - ``DashboardView``
/// - ``DashboardViewModel``
///
/// ### Sub-Modules
/// - ``StatsWidget``
/// - ``ActivityFeed``
/// - ``QuickActions``
/// - ``SystemHealth``
///
/// ### Data Models
/// - ``DashboardMetrics``
/// - ``ActivityItem``
/// - ``ProjectSummary``
///
/// ### Version History
/// - v1.5.2: Added Feature21 support with enhanced metrics
/// - v1.5.1: Performance improvements for large datasets
/// - v1.5.0: Introduced sub-module architecture
/// - v1.0.0: Initial dashboard implementation
///
/// ## Usage
/// ```swift
/// // Load the dashboard module
/// let dashboard = DashboardModule()
/// try await moduleManager.loadModule(dashboard)
///
/// // Access dashboard metrics
/// let metrics = dashboard.currentMetrics
/// print("Active projects: \(metrics.activeProjects)")
///
/// // Send refresh command
/// let message = ModuleMessage(
///     source: "com.bridge.app",
///     destination: "com.bridge.dashboard",
///     type: "refresh"
/// )
/// try await dashboard.receiveMessage(message)
/// ```
///
/// ## Architecture
///
/// The Dashboard module follows a clean MVVM architecture:
/// - **Model**: Core data structures and business logic
/// - **View**: SwiftUI views for presentation
/// - **ViewModel**: ObservableObject managing view state
///
/// Sub-modules are loaded dynamically and communicate through the module messaging system.
@MainActor
public class DashboardModule: BridgeModule {
    
    /// The unique identifier for this module
    ///
    /// This identifier is used by the ModuleManager for hot-swapping
    /// and version tracking. Never change this value once deployed.
    ///
    /// - Important: Follows reverse-DNS notation for uniqueness
    public let id = "com.bridge.dashboard"
    
    /// Human-readable name displayed in the sidebar
    ///
    /// This name appears in the navigation and module selection UI.
    /// Keep it concise but descriptive.
    ///
    /// - Note: Can be localized in future versions
    public let displayName = "Dashboard"
    
    /// SF Symbol icon name for the module
    ///
    /// Used in navigation, tabs, and module selection interfaces.
    /// Should be recognizable and match the module's purpose.
    ///
    /// - Tip: Use SF Symbols 4+ for gradient support
    public let icon = "square.grid.2x2"
    
    /// Current version of the Dashboard module
    ///
    /// Follows semantic versioning for clear communication of changes.
    /// Updated independently from the main application version.
    public let version = ModuleVersion(major: 1, minor: 5, patch: 2)
    
    /// View model managing dashboard state
    ///
    /// Published to enable SwiftUI automatic updates when state changes.
    @Published private var viewModel = DashboardViewModel()
    
    /// Sub-modules contained within Dashboard
    ///
    /// Each widget is a fully independent module that can be
    /// hot-swapped without affecting the rest of the dashboard.
    public var subModules: [String: any BridgeModule] = [:]
    
    /// Dependencies required by this module
    ///
    /// Dashboard has no hard dependencies but can integrate
    /// with other modules when available.
    public let dependencies: [String] = []
    
    /// The main SwiftUI view for this module
    ///
    /// Returns the dashboard interface wrapped in AnyView for type erasure.
    /// The view automatically updates when the view model state changes.
    public var view: AnyView {
        AnyView(
            DashboardView(viewModel: viewModel)
                .environmentObject(viewModel)
        )
    }
    
    /// Initialize the Dashboard module
    ///
    /// Sets up the module and loads default sub-modules.
    public init() {
        setupSubModules()
    }
    
    /// Initialize module resources and state
    ///
    /// Called when the module is first loaded into memory. Sets up:
    /// - Data connections to project database
    /// - Activity monitoring listeners
    /// - System health watchers
    /// - User preferences
    ///
    /// - Throws: ModuleError if initialization fails
    public func initialize() async throws {
        print("🚀 Initializing Dashboard module v\(version)")
        
        // Load saved dashboard configuration
        await viewModel.loadConfiguration()
        
        // Start monitoring system metrics
        await viewModel.startMetricsMonitoring()
        
        // Initialize sub-modules
        for (_, subModule) in subModules {
            try await subModule.initialize()
        }
        
        print("✅ Dashboard module initialized successfully")
    }
    
    /// Clean up module resources before unloading
    ///
    /// Called before the module is removed from memory. Ensures:
    /// - All data is saved
    /// - Monitors are stopped
    /// - Resources are released
    /// - Sub-modules are cleaned up
    ///
    /// - Important: Must complete within 5 seconds
    public func cleanup() async {
        print("🧹 Cleaning up Dashboard module")
        
        // Stop metrics monitoring
        await viewModel.stopMetricsMonitoring()
        
        // Save current configuration
        await viewModel.saveConfiguration()
        
        // Cleanup sub-modules
        for (_, subModule) in subModules {
            await subModule.cleanup()
        }
        
        print("✅ Dashboard cleanup complete")
    }
    
    /// Check if the module can be safely unloaded
    ///
    /// Returns false if there are unsaved changes or critical
    /// operations in progress.
    ///
    /// - Returns: true if safe to unload, false otherwise
    public func canUnload() -> Bool {
        // Check if any critical operations are in progress
        guard !viewModel.hasUnsavedChanges else {
            print("⚠️ Dashboard has unsaved changes")
            return false
        }
        
        // Check sub-modules
        for (id, subModule) in subModules {
            if !subModule.canUnload() {
                print("⚠️ Sub-module \(id) cannot be unloaded")
                return false
            }
        }
        
        return true
    }
    
    /// Receive a message from another module
    ///
    /// Handles cross-module communication for dashboard operations.
    /// Supported message types:
    /// - `refresh`: Refresh all dashboard data
    /// - `updateMetrics`: Update specific metrics
    /// - `showActivity`: Display activity for specific project
    ///
    /// - Parameter message: The message to process
    /// - Throws: ModuleError if message cannot be processed
    public func receiveMessage(_ message: ModuleMessage) async throws {
        print("📬 Dashboard received message: \(message.type) from \(message.source)")
        
        switch message.type {
        case "refresh":
            await viewModel.refreshAllData()
            
        case "updateMetrics":
            if let metrics = message.payload["metrics"] as? [String: Any] {
                await viewModel.updateMetrics(metrics)
            }
            
        case "showActivity":
            if let projectId = message.payload["projectId"] as? String {
                await viewModel.showActivityForProject(projectId)
            }
            
        default:
            // Try sub-modules
            if let destination = message.payload["subModule"] as? String,
               let subModule = subModules[destination] {
                try await subModule.receiveMessage(message)
            } else {
                print("⚠️ Unknown message type: \(message.type)")
            }
        }
    }
    
    // MARK: - Private Methods
    
    /// Set up dashboard sub-modules
    private func setupSubModules() {
        // Initialize sub-modules
        subModules = [
            "com.bridge.dashboard.stats": StatsWidget(),
            "com.bridge.dashboard.activity": ActivityFeed(),
            "com.bridge.dashboard.quickactions": QuickActions(),
            "com.bridge.dashboard.health": SystemHealth()
        ]
    }
}

/// # DashboardView
///
/// The main view for the Dashboard module, displaying project metrics,
/// activity feed, and system status in a beautiful Arc Browser-inspired design.
///
/// ## Overview
///
/// DashboardView uses a responsive grid layout that adapts to different
/// window sizes. Each section is a self-contained widget that can be
/// updated independently.
///
/// ## Topics
///
/// ### Layout Components
/// - Stats grid with animated cards
/// - Activity timeline with live updates
/// - Quick action buttons
/// - System health indicators
public struct DashboardView: View {
    
    /// View model containing dashboard state
    @ObservedObject var viewModel: DashboardViewModel
    
    /// Animation namespace for smooth transitions
    @Namespace private var animation
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                headerSection
                
                // Stats Grid
                statsGrid
                
                // Activity and Quick Actions
                HStack(alignment: .top, spacing: 20) {
                    activitySection
                    quickActionsSection
                }
                
                // System Health
                systemHealthSection
            }
            .padding(24)
        }
        .background(LinearGradient.subtleBackground)
        .onAppear {
            viewModel.viewAppeared()
        }
    }
    
    /// Dashboard header with title and refresh button
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("Dashboard")
                    .font(BridgeTypography.largeTitle)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.bridgeTextPrimary, .bridgePrimary],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Text(viewModel.greeting)
                    .font(BridgeTypography.body)
                    .foregroundColor(.bridgeTextSecondary)
            }
            
            Spacer()
            
            Button(action: { Task { await viewModel.refreshAllData() } }) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 18))
                    .foregroundStyle(LinearGradient.arcPrimary)
                    .rotationEffect(.degrees(viewModel.isRefreshing ? 360 : 0))
                    .animation(
                        viewModel.isRefreshing ? .linear(duration: 1).repeatForever(autoreverses: false) : .default,
                        value: viewModel.isRefreshing
                    )
            }
            .buttonStyle(.plain)
        }
    }
    
    /// Statistics grid showing key metrics
    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
            ForEach(viewModel.stats) { stat in
                StatCardView(stat: stat)
                    .matchedGeometryEffect(id: stat.id, in: animation)
            }
        }
    }
    
    /// Recent activity section
    private var activitySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Activity")
                .font(BridgeTypography.title2)
                .foregroundColor(.bridgeTextPrimary)
            
            VStack(spacing: 12) {
                ForEach(viewModel.recentActivity) { activity in
                    ActivityRowView(activity: activity)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    /// Quick actions section
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(BridgeTypography.title2)
                .foregroundColor(.bridgeTextPrimary)
            
            VStack(spacing: 8) {
                ForEach(viewModel.quickActions) { action in
                    QuickActionButton(action: action)
                }
            }
        }
        .frame(width: 200)
    }
    
    /// System health indicators
    private var systemHealthSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("System Health")
                .font(BridgeTypography.title2)
                .foregroundColor(.bridgeTextPrimary)
            
            HStack(spacing: 20) {
                ForEach(viewModel.healthIndicators) { indicator in
                    HealthIndicatorView(indicator: indicator)
                }
            }
        }
    }
}

/// # DashboardViewModel
///
/// View model managing the state and business logic for the Dashboard module.
/// Handles data fetching, real-time updates, and user interactions.
///
/// ## Topics
///
/// ### State Management
/// - ``stats``
/// - ``recentActivity``
/// - ``quickActions``
/// - ``healthIndicators``
///
/// ### Data Operations
/// - ``refreshAllData()``
/// - ``updateMetrics(_:)``
/// - ``startMetricsMonitoring()``
@MainActor
public class DashboardViewModel: ObservableObject {
    
    /// Current statistics to display
    @Published var stats: [DashboardStat] = []
    
    /// Recent activity items
    @Published var recentActivity: [ActivityItem] = []
    
    /// Available quick actions
    @Published var quickActions: [QuickAction] = []
    
    /// System health indicators
    @Published var healthIndicators: [HealthIndicator] = []
    
    /// Loading state for refresh operations
    @Published var isRefreshing = false
    
    /// Indicates unsaved changes
    @Published var hasUnsavedChanges = false
    
    /// Personalized greeting based on time of day
    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Good morning! Ready to build something amazing?"
        case 12..<17: return "Good afternoon! Your projects are looking great."
        case 17..<22: return "Good evening! Still crushing it today?"
        default: return "Working late? Your dedication is inspiring!"
        }
    }
    
    /// Initialize view model with default data
    init() {
        loadDefaultData()
    }
    
    /// Called when view appears
    func viewAppeared() {
        Task {
            await refreshAllData()
        }
    }
    
    /// Refresh all dashboard data
    ///
    /// Fetches latest metrics, activity, and system status.
    /// Shows loading indicator during refresh.
    public func refreshAllData() async {
        isRefreshing = true
        
        // Simulate data fetching
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Update all data
        updateStats()
        updateActivity()
        updateHealth()
        
        isRefreshing = false
        hasUnsavedChanges = false
    }
    
    /// Update specific metrics
    ///
    /// - Parameter metrics: Dictionary of metric updates
    public func updateMetrics(_ metrics: [String: Any]) async {
        // Update relevant stats based on metrics
        if let activeProjects = metrics["activeProjects"] as? Int {
            if let index = stats.firstIndex(where: { $0.title == "Active Projects" }) {
                stats[index].value = "\(activeProjects)"
            }
        }
        
        hasUnsavedChanges = true
    }
    
    /// Show activity for specific project
    public func showActivityForProject(_ projectId: String) async {
        // Filter activity to show only items for specified project
        // This would fetch from Core Data in production
        print("Showing activity for project: \(projectId)")
    }
    
    /// Start monitoring system metrics
    public func startMetricsMonitoring() async {
        // Set up timers and observers for real-time updates
        print("📊 Started metrics monitoring")
    }
    
    /// Stop monitoring system metrics
    public func stopMetricsMonitoring() async {
        // Clean up timers and observers
        print("📊 Stopped metrics monitoring")
    }
    
    /// Load saved configuration
    public func loadConfiguration() async {
        // Load user preferences and saved state
        print("📂 Loading dashboard configuration")
    }
    
    /// Save current configuration
    public func saveConfiguration() async {
        // Persist user preferences and state
        print("💾 Saving dashboard configuration")
        hasUnsavedChanges = false
    }
    
    // MARK: - Private Methods
    
    /// Load default data for initial display
    private func loadDefaultData() {
        stats = [
            DashboardStat(
                id: "projects",
                title: "Active Projects",
                value: "12",
                icon: "folder.fill",
                gradient: .projectsGradient
            ),
            DashboardStat(
                id: "modules",
                title: "Loaded Modules",
                value: "8",
                icon: "square.grid.3x3.fill",
                gradient: .dashboardGradient
            ),
            DashboardStat(
                id: "builds",
                title: "Recent Builds",
                value: "24",
                icon: "hammer.fill",
                gradient: .terminalGradient
            ),
            DashboardStat(
                id: "storage",
                title: "Storage Used",
                value: "2.4 GB",
                icon: "externaldrive.fill",
                gradient: .arcSecondary
            )
        ]
        
        quickActions = [
            QuickAction(id: "new-project", title: "New Project", icon: "plus.circle.fill"),
            QuickAction(id: "build", title: "Build All", icon: "hammer.circle.fill"),
            QuickAction(id: "docs", title: "Documentation", icon: "book.circle.fill")
        ]
    }
    
    /// Update statistics data
    private func updateStats() {
        // In production, fetch from Core Data
        stats[0].value = "\(Int.random(in: 10...20))"
        stats[1].value = "\(Int.random(in: 5...10))"
    }
    
    /// Update activity feed
    private func updateActivity() {
        recentActivity = [
            ActivityItem(
                id: UUID().uuidString,
                title: "Dashboard Module Updated",
                subtitle: "Version 1.5.2 hot-swapped successfully",
                icon: "arrow.triangle.2.circlepath",
                timestamp: Date(),
                type: .update
            ),
            ActivityItem(
                id: UUID().uuidString,
                title: "New Feature Added",
                subtitle: "Feature21 integrated into Projects module",
                icon: "sparkles",
                timestamp: Date().addingTimeInterval(-3600),
                type: .feature
            ),
            ActivityItem(
                id: UUID().uuidString,
                title: "Build Completed",
                subtitle: "BridgeMac v2.0.0 built successfully",
                icon: "checkmark.circle.fill",
                timestamp: Date().addingTimeInterval(-7200),
                type: .build
            )
        ]
    }
    
    /// Update system health indicators
    private func updateHealth() {
        healthIndicators = [
            HealthIndicator(id: "cpu", name: "CPU", value: 0.35, status: .good),
            HealthIndicator(id: "memory", name: "Memory", value: 0.62, status: .warning),
            HealthIndicator(id: "disk", name: "Disk", value: 0.28, status: .good),
            HealthIndicator(id: "network", name: "Network", value: 0.15, status: .good)
        ]
    }
}

// MARK: - Supporting Models

/// Dashboard statistic model
public struct DashboardStat: Identifiable {
    public let id: String
    public var title: String
    public var value: String
    public var icon: String
    public var gradient: LinearGradient
}

/// Activity item model
public struct ActivityItem: Identifiable {
    public let id: String
    public let title: String
    public let subtitle: String
    public let icon: String
    public let timestamp: Date
    public let type: ActivityType
    
    public enum ActivityType {
        case update, feature, build, error
    }
}

/// Quick action model
public struct QuickAction: Identifiable {
    public let id: String
    public let title: String
    public let icon: String
}

/// Health indicator model
public struct HealthIndicator: Identifiable {
    public let id: String
    public let name: String
    public let value: Double // 0.0 to 1.0
    public let status: Status
    
    public enum Status {
        case good, warning, critical
    }
}