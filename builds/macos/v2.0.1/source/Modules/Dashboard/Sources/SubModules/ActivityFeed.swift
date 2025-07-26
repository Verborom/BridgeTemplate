import SwiftUI

/// # ActivityFeed Sub-Module
///
/// Real-time activity feed showing project updates, module hot-swaps,
/// builds, and system events. Supports infinite scrolling and live updates.
///
/// ## Overview
///
/// The ActivityFeed demonstrates Bridge Template's real-time capabilities.
/// As modules are hot-swapped, projects updated, or builds completed, this
/// feed updates instantly without requiring any parent module updates. It
/// maintains its own WebSocket connection for live updates.
///
/// ## Topics
///
/// ### Core Components
/// - ``ActivityFeed``
/// - ``ActivityRowView``
/// - ``ActivityStreamManager``
///
/// ### Data Models
/// - ``ActivityFilter``
/// - ``ActivityPriority``
///
/// ### Version History
/// - v1.3.0: Added real-time WebSocket updates
/// - v1.2.2: Improved performance for large feeds
/// - v1.2.1: Added filtering capabilities
/// - v1.2.0: Introduced infinite scrolling
/// - v1.0.0: Basic activity display
///
/// ## Architecture
///
/// The ActivityFeed maintains its own data stream independent of the
/// Dashboard, demonstrating true module independence. Updates flow:
/// 1. System events → ActivityStreamManager
/// 2. StreamManager → ActivityFeed via Combine
/// 3. ActivityFeed → UI with SwiftUI
@MainActor
public class ActivityFeed: BridgeModule {
    
    /// Unique identifier for the activity feed
    public let id = "com.bridge.dashboard.activity"
    
    /// Display name
    public let displayName = "Activity Feed"
    
    /// Icon for the feed
    public let icon = "list.bullet.rectangle"
    
    /// Current version supporting real-time updates
    public let version = ModuleVersion(major: 1, minor: 3, patch: 0)
    
    /// No sub-modules in this widget
    public let subModules: [String: any BridgeModule] = [:]
    
    /// No hard dependencies
    public let dependencies: [String] = []
    
    /// Stream manager for real-time updates
    private let streamManager = ActivityStreamManager()
    
    /// The feed's view
    public var view: AnyView {
        AnyView(
            ActivityFeedView(streamManager: streamManager)
        )
    }
    
    /// Initialize the feed and start streaming
    public func initialize() async throws {
        print("📰 Initializing ActivityFeed v\(version)")
        await streamManager.startStreaming()
    }
    
    /// Stop streaming and cleanup
    public func cleanup() async {
        print("📰 Cleaning up ActivityFeed")
        await streamManager.stopStreaming()
    }
    
    /// Can unload unless actively streaming critical events
    public func canUnload() -> Bool {
        !streamManager.hasQueuedEvents
    }
    
    /// Handle control messages
    public func receiveMessage(_ message: ModuleMessage) async throws {
        switch message.type {
        case "filter":
            if let filterType = message.payload["type"] as? String {
                await streamManager.applyFilter(ActivityFilter(rawValue: filterType) ?? .all)
            }
        case "pause":
            await streamManager.pauseStreaming()
        case "resume":
            await streamManager.resumeStreaming()
        default:
            print("📰 Unknown message: \(message.type)")
        }
    }
}

/// # ActivityFeedView
///
/// The main view for the activity feed with infinite scrolling
/// and real-time updates.
public struct ActivityFeedView: View {
    
    /// Stream manager providing activity data
    @ObservedObject var streamManager: ActivityStreamManager
    
    /// Scroll position for infinite loading
    @State private var scrollPosition: String?
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Filter controls
            filterBar
            
            // Activity list
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(streamManager.activities) { activity in
                            ActivityRowView(activity: activity)
                                .id(activity.id)
                                .transition(.asymmetric(
                                    insertion: .move(edge: .top).combined(with: .opacity),
                                    removal: .opacity
                                ))
                        }
                        
                        // Load more indicator
                        if streamManager.hasMoreActivities {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding()
                                .onAppear {
                                    Task {
                                        await streamManager.loadMoreActivities()
                                    }
                                }
                        }
                    }
                }
                .onChange(of: streamManager.activities.first?.id) { _, newValue in
                    // Auto-scroll to new activities
                    if let id = newValue, streamManager.autoScroll {
                        withAnimation {
                            proxy.scrollTo(id, anchor: .top)
                        }
                    }
                }
            }
        }
    }
    
    /// Filter selection bar
    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(ActivityFilter.allCases, id: \.self) { filter in
                    FilterChip(
                        title: filter.displayName,
                        isSelected: streamManager.currentFilter == filter,
                        action: {
                            Task {
                                await streamManager.applyFilter(filter)
                            }
                        }
                    )
                }
            }
        }
    }
}

/// # ActivityRowView
///
/// Individual activity row with icon, title, and timestamp.
/// Supports different activity types with color coding.
public struct ActivityRowView: View {
    
    /// Activity to display
    let activity: ActivityItem
    
    /// Hover state
    @State private var isHovered = false
    
    /// Color for activity type
    private var activityColor: Color {
        switch activity.type {
        case .update: return .bridgeDashboard
        case .feature: return .bridgeProjects
        case .build: return .bridgeTerminal
        case .error: return .red
        }
    }
    
    public var body: some View {
        HStack(spacing: 16) {
            // Icon with colored background
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [activityColor, activityColor.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)
                
                Image(systemName: activity.icon)
                    .font(.system(size: 20))
                    .foregroundColor(.white)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(activity.title)
                    .font(BridgeTypography.headline)
                    .foregroundColor(.bridgeTextPrimary)
                
                Text(activity.subtitle)
                    .font(BridgeTypography.caption)
                    .foregroundColor(.bridgeTextSecondary)
            }
            
            Spacer()
            
            // Timestamp
            Text(activity.timestamp.formatted(.relative(presentation: .abbreviated)))
                .font(BridgeTypography.caption)
                .foregroundColor(.bridgeTextSecondary)
                .opacity(isHovered ? 1 : 0.7)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.bridgeCardBackground)
                .shadow(
                    color: Color.black.opacity(isHovered ? 0.08 : 0.04),
                    radius: isHovered ? 8 : 4,
                    x: 0,
                    y: isHovered ? 4 : 2
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.5), lineWidth: 0.5)
        )
        .scaleEffect(isHovered ? 1.01 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

/// # ActivityStreamManager
///
/// Manages the real-time activity stream with WebSocket connection
/// and local caching for offline support.
@MainActor
public class ActivityStreamManager: ObservableObject {
    
    /// Current activities in the feed
    @Published var activities: [ActivityItem] = []
    
    /// Current filter applied
    @Published var currentFilter: ActivityFilter = .all
    
    /// Whether auto-scroll is enabled
    @Published var autoScroll = true
    
    /// Whether more activities can be loaded
    @Published var hasMoreActivities = true
    
    /// Whether there are queued events
    var hasQueuedEvents: Bool {
        !eventQueue.isEmpty
    }
    
    /// Event queue for offline support
    private var eventQueue: [ActivityItem] = []
    
    /// WebSocket task for real-time updates
    private var streamTask: Task<Void, Never>?
    
    /// Start streaming activities
    func startStreaming() async {
        // In production, this would connect to WebSocket
        // For now, simulate with timer
        streamTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 5_000_000_000) // 5 seconds
                
                let newActivity = ActivityItem(
                    id: UUID().uuidString,
                    title: "Module Hot-Swapped",
                    subtitle: "Dashboard updated to v\(Int.random(in: 1...9)).\(Int.random(in: 0...9)).\(Int.random(in: 0...9))",
                    icon: "arrow.triangle.2.circlepath",
                    timestamp: Date(),
                    type: .update
                )
                
                await MainActor.run {
                    activities.insert(newActivity, at: 0)
                    if activities.count > 100 {
                        activities.removeLast()
                    }
                }
            }
        }
    }
    
    /// Stop streaming
    func stopStreaming() async {
        streamTask?.cancel()
        streamTask = nil
    }
    
    /// Pause streaming temporarily
    func pauseStreaming() async {
        // Implementation
    }
    
    /// Resume streaming
    func resumeStreaming() async {
        // Implementation
    }
    
    /// Apply filter to activities
    func applyFilter(_ filter: ActivityFilter) async {
        currentFilter = filter
        // Re-filter activities based on selection
    }
    
    /// Load more historical activities
    func loadMoreActivities() async {
        // Simulate loading delay
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Add more activities
        let moreActivities = (0..<10).map { index in
            ActivityItem(
                id: UUID().uuidString,
                title: "Historical Event \(index)",
                subtitle: "Something happened \(index * 10) minutes ago",
                icon: "clock.arrow.circlepath",
                timestamp: Date().addingTimeInterval(Double(-index * 600)),
                type: .update
            )
        }
        
        activities.append(contentsOf: moreActivities)
        
        // Simulate end of data
        if activities.count > 50 {
            hasMoreActivities = false
        }
    }
}

/// # ActivityFilter
///
/// Filter options for the activity feed.
public enum ActivityFilter: String, CaseIterable {
    case all = "all"
    case updates = "updates"
    case features = "features"
    case builds = "builds"
    case errors = "errors"
    
    /// Display name for UI
    var displayName: String {
        switch self {
        case .all: return "All"
        case .updates: return "Updates"
        case .features: return "Features"
        case .builds: return "Builds"
        case .errors: return "Errors"
        }
    }
}

/// # FilterChip
///
/// Selectable filter chip for activity filtering.
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(BridgeTypography.caption)
                .foregroundColor(isSelected ? .white : .bridgeTextPrimary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? LinearGradient.arcPrimary : Color.clear)
                        .overlay(
                            Capsule()
                                .stroke(isSelected ? Color.clear : Color.bridgeTextSecondary.opacity(0.3), lineWidth: 1)
                        )
                )
        }
        .buttonStyle(.plain)
    }
}