import SwiftUI

// MARK: - Mock Dashboard Module

class MockDashboardModule: BridgeModule, ObservableObject {
    let id = "com.bridge.dashboard"
    let displayName = "Dashboard"
    let icon = "chart.bar.fill"
    let version = ModuleVersion(major: 1, minor: 5, patch: 2)
    let dependencies: [String] = []
    
    // Sub-modules
    lazy var subModules: [String: any BridgeModule] = [
        "com.bridge.dashboard.stats": StatsWidgetModule(),
        "com.bridge.dashboard.activity": ActivityFeedModule(),
        "com.bridge.dashboard.actions": QuickActionsModule(),
        "com.bridge.dashboard.health": SystemHealthModule()
    ]
    
    var view: AnyView {
        AnyView(DashboardView())
    }
    
    func initialize() async throws {
        print("🚀 Dashboard module initialized")
    }
    
    func cleanup() async {
        print("🧹 Dashboard module cleaned up")
    }
    
    func canUnload() -> Bool {
        true
    }
    
    func receiveMessage(_ message: ModuleMessage) async throws {
        print("📨 Dashboard received message: \(message.type)")
    }
}

// Dashboard View
struct DashboardView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                HStack {
                    VStack(alignment: .leading) {
                        Text("Dashboard")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Text("Real-time project insights")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding()
                
                // Stats Grid
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    StatCard(title: "Active Projects", value: "12", icon: "folder.fill", color: .blue)
                    StatCard(title: "Completed Tasks", value: "247", icon: "checkmark.circle.fill", color: .green)
                    StatCard(title: "Team Members", value: "8", icon: "person.3.fill", color: .purple)
                    StatCard(title: "Code Coverage", value: "94%", icon: "chart.pie.fill", color: .orange)
                }
                .padding(.horizontal)
                
                // Activity Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Recent Activity")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.horizontal)
                    
                    VStack(spacing: 8) {
                        ActivityRow(time: "2 min ago", action: "Module hot-swapped", detail: "Dashboard v1.5.2")
                        ActivityRow(time: "15 min ago", action: "Build completed", detail: "v2.0.1")
                        ActivityRow(time: "1 hour ago", action: "Documentation updated", detail: "ModuleManager API")
                        ActivityRow(time: "3 hours ago", action: "Test suite passed", detail: "All 156 tests")
                    }
                    .padding(.horizontal)
                }
                .padding(.top)
            }
        }
        .background(Color(NSColor.controlBackgroundColor))
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                Spacer()
            }
            
            Text(value)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct ActivityRow: View {
    let time: String
    let action: String
    let detail: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(action)
                    .font(.headline)
                Text(detail)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text(time)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
        .cornerRadius(8)
    }
}

// MARK: - Mock Projects Module

class MockProjectsModule: BridgeModule, ObservableObject {
    let id = "com.bridge.projects"
    let displayName = "Projects"
    let icon = "folder.badge.gearshape"
    let version = ModuleVersion(major: 1, minor: 8, patch: 1)
    let dependencies = ["com.bridge.dashboard"]
    let subModules: [String: any BridgeModule] = [:]
    
    var view: AnyView {
        AnyView(ProjectsView())
    }
    
    func initialize() async throws {
        print("🚀 Projects module initialized")
    }
    
    func cleanup() async {
        print("🧹 Projects module cleaned up")
    }
    
    func canUnload() -> Bool {
        true
    }
    
    func receiveMessage(_ message: ModuleMessage) async throws {
        print("📨 Projects received message: \(message.type)")
    }
}

struct ProjectsView: View {
    let projects = [
        ("Bridge Template", "Active", Color.green),
        ("Documentation Generator", "In Progress", Color.orange),
        ("Module Builder", "Planning", Color.blue),
        ("Test Framework", "Completed", Color.gray)
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack {
                    VStack(alignment: .leading) {
                        Text("Projects")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Text("Manage your development projects")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Button(action: {}) {
                        Label("New Project", systemImage: "plus.circle.fill")
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                
                // Project List
                LazyVStack(spacing: 12) {
                    ForEach(projects, id: \.0) { project in
                        ProjectRow(name: project.0, status: project.1, statusColor: project.2)
                    }
                }
                .padding(.horizontal)
            }
        }
        .background(Color(NSColor.controlBackgroundColor))
    }
}

struct ProjectRow: View {
    let name: String
    let status: String
    let statusColor: Color
    
    var body: some View {
        HStack {
            Image(systemName: "folder.fill")
                .font(.title2)
                .foregroundColor(.blue)
            
            VStack(alignment: .leading) {
                Text(name)
                    .font(.headline)
                Text("Last updated 2 hours ago")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(status)
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(statusColor.opacity(0.2))
                .foregroundColor(statusColor)
                .cornerRadius(12)
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Mock Terminal Module

class MockTerminalModule: BridgeModule, ObservableObject {
    let id = "com.bridge.terminal"
    let displayName = "Terminal"
    let icon = "terminal.fill"
    let version = ModuleVersion(major: 1, minor: 2, patch: 0)
    let dependencies: [String] = []
    let subModules: [String: any BridgeModule] = [:]
    
    var view: AnyView {
        AnyView(TerminalView())
    }
    
    func initialize() async throws {
        print("🚀 Terminal module initialized")
    }
    
    func cleanup() async {
        print("🧹 Terminal module cleaned up")
    }
    
    func canUnload() -> Bool {
        true
    }
    
    func receiveMessage(_ message: ModuleMessage) async throws {
        print("📨 Terminal received message: \(message.type)")
    }
}

struct TerminalView: View {
    @State private var output = """
    Bridge Terminal v1.2.0
    Ready for commands...
    
    $ bridge module list
    ✓ com.bridge.dashboard (v1.5.2)
    ✓ com.bridge.projects (v1.8.1)
    ✓ com.bridge.terminal (v1.2.0)
    
    $ bridge module hot-swap dashboard 1.6.0
    🔄 Hot-swapping com.bridge.dashboard to v1.6.0...
    ✅ Hot-swap successful!
    
    $ _
    """
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Terminal")
                    .font(.headline)
                Spacer()
                Button(action: {}) {
                    Image(systemName: "trash")
                }
                .buttonStyle(.plain)
            }
            .padding()
            .background(Color(NSColor.windowBackgroundColor))
            
            // Terminal Output
            ScrollView {
                Text(output)
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.green)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
            .background(Color.black)
            
            // Input Field
            HStack {
                Text("$")
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.green)
                TextField("Enter command...", text: .constant(""))
                    .textFieldStyle(.plain)
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.green)
            }
            .padding()
            .background(Color.black.opacity(0.8))
        }
        .background(Color.black)
    }
}

// MARK: - Dashboard Sub-modules

class StatsWidgetModule: BridgeModule, ObservableObject {
    let id = "com.bridge.dashboard.stats"
    let displayName = "Stats Widget"
    let icon = "chart.bar.xaxis"
    let version = ModuleVersion(major: 1, minor: 2, patch: 1)
    let dependencies: [String] = []
    let subModules: [String: any BridgeModule] = [:]
    
    var view: AnyView {
        AnyView(Text("Stats Widget"))
    }
    
    func initialize() async throws {}
    func cleanup() async {}
    func canUnload() -> Bool { true }
    func receiveMessage(_ message: ModuleMessage) async throws {}
}

class ActivityFeedModule: BridgeModule, ObservableObject {
    let id = "com.bridge.dashboard.activity"
    let displayName = "Activity Feed"
    let icon = "list.bullet.circle"
    let version = ModuleVersion(major: 1, minor: 3, patch: 0)
    let dependencies: [String] = []
    let subModules: [String: any BridgeModule] = [:]
    
    var view: AnyView {
        AnyView(Text("Activity Feed"))
    }
    
    func initialize() async throws {}
    func cleanup() async {}
    func canUnload() -> Bool { true }
    func receiveMessage(_ message: ModuleMessage) async throws {}
}

class QuickActionsModule: BridgeModule, ObservableObject {
    let id = "com.bridge.dashboard.actions"
    let displayName = "Quick Actions"
    let icon = "bolt.circle"
    let version = ModuleVersion(major: 1, minor: 1, patch: 0)
    let dependencies: [String] = []
    let subModules: [String: any BridgeModule] = [:]
    
    var view: AnyView {
        AnyView(Text("Quick Actions"))
    }
    
    func initialize() async throws {}
    func cleanup() async {}
    func canUnload() -> Bool { true }
    func receiveMessage(_ message: ModuleMessage) async throws {}
}

class SystemHealthModule: BridgeModule, ObservableObject {
    let id = "com.bridge.dashboard.health"
    let displayName = "System Health"
    let icon = "heart.circle"
    let version = ModuleVersion(major: 1, minor: 0, patch: 3)
    let dependencies: [String] = []
    let subModules: [String: any BridgeModule] = [:]
    
    var view: AnyView {
        AnyView(Text("System Health"))
    }
    
    func initialize() async throws {}
    func cleanup() async {}
    func canUnload() -> Bool { true }
    func receiveMessage(_ message: ModuleMessage) async throws {}
}