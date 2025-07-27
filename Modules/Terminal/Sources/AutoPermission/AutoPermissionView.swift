import SwiftUI

/// # Auto-Permission View
///
/// The user interface for managing and monitoring the auto-permission system.
/// This view provides controls for configuring unattended execution, managing
/// credentials, viewing active permissions, and reviewing audit logs.
///
/// ## Overview
///
/// The Auto-Permission View serves as the control center for:
/// - Enabling/disabling unattended mode
/// - Configuring permission policies
/// - Managing secure credentials
/// - Monitoring active permission grants
/// - Reviewing audit history
/// - Testing permission scenarios
///
/// ## Topics
///
/// ### Main Views
/// - ``AutoPermissionView``
/// - ``PermissionConfigurationView``
/// - ``ActiveGrantsView``
/// - ``AuditLogView``
///
/// ### Configuration Views
/// - ``UnattendedModeView``
/// - ``CredentialManagementView``
/// - ``PolicyEditorView``
///
/// ## Usage
/// ```swift
/// AutoPermissionView(autoPermission: autoPermissionSystem)
///     .frame(minWidth: 600, minHeight: 400)
/// ```
public struct AutoPermissionView: View {
    
    /// Auto-permission system instance
    @ObservedObject var autoPermission: AutoPermissionSystem
    
    /// View state
    @State private var selectedTab = "status"
    @State private var showingCredentialSheet = false
    @State private var showingPolicyEditor = false
    @State private var testCommand = ""
    @State private var testResult: PermissionExecutionResult?
    
    /// Computed properties
    private var sessionGrantsCount: Int {
        autoPermission.activeGrants.filter { grant in
            if case .session = grant.scope { return true }
            return false
        }.count
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView
            
            // Tab selection
            tabBar
            
            // Content
            Group {
                switch selectedTab {
                case "status":
                    statusView
                case "config":
                    configurationView
                case "grants":
                    activeGrantsView
                case "audit":
                    auditLogView
                case "test":
                    testingView
                default:
                    statusView
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color(NSColor.controlBackgroundColor))
        .sheet(isPresented: $showingCredentialSheet) {
            CredentialManagementView(autoPermission: autoPermission)
        }
        .sheet(isPresented: $showingPolicyEditor) {
            PolicyEditorView(autoPermission: autoPermission)
        }
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        HStack {
            Image(systemName: "lock.shield")
                .font(.title2)
                .foregroundStyle(
                    autoPermission.isActive ?
                    LinearGradient(colors: [.green, .blue], startPoint: .topLeading, endPoint: .bottomTrailing) :
                    LinearGradient(colors: [.gray], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
            
            VStack(alignment: .leading) {
                Text("Auto-Permission System")
                    .font(.headline)
                Text(autoPermission.isActive ? "Active" : "Inactive")
                    .font(.caption)
                    .foregroundColor(autoPermission.isActive ? .green : .gray)
            }
            
            Spacer()
            
            // Activation toggle
            Toggle("", isOn: $autoPermission.isActive)
                .toggleStyle(SwitchToggleStyle())
                .scaleEffect(0.8)
        }
        .padding()
        .background(Color(NSColor.windowBackgroundColor))
    }
    
    // MARK: - Tab Bar
    
    private var tabBar: some View {
        HStack(spacing: 0) {
            TabButton(title: "Status", icon: "info.circle", id: "status", selection: $selectedTab)
            TabButton(title: "Configuration", icon: "gear", id: "config", selection: $selectedTab)
            TabButton(title: "Active Grants", icon: "checkmark.shield", id: "grants", selection: $selectedTab)
            TabButton(title: "Audit Log", icon: "doc.text.magnifyingglass", id: "audit", selection: $selectedTab)
            TabButton(title: "Test", icon: "hammer", id: "test", selection: $selectedTab)
        }
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    // MARK: - Status View
    
    private var statusView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // System status
                StatusCard(
                    title: "System Status",
                    icon: "checkmark.circle.fill",
                    color: autoPermission.isActive ? .green : .gray
                ) {
                    VStack(alignment: .leading, spacing: 8) {
                        StatusRow(label: "Status", value: autoPermission.isActive ? "Active" : "Inactive")
                        StatusRow(label: "Mode", value: autoPermission.configuration.unattendedMode ? "Unattended" : "Interactive")
                        StatusRow(label: "Active Grants", value: "\(autoPermission.activeGrants.count)")
                        StatusRow(label: "Audit Logging", value: autoPermission.configuration.auditingEnabled ? "Enabled" : "Disabled")
                    }
                }
                
                // Quick stats
                HStack(spacing: 16) {
                    StatCard(
                        title: "Total Grants",
                        value: "\(autoPermission.activeGrants.count)",
                        icon: "key.fill",
                        color: .blue
                    )
                    
                    StatCard(
                        title: "Session Grants",
                        value: "\(sessionGrantsCount)",
                        icon: "clock.fill",
                        color: .orange
                    )
                    
                    StatCard(
                        title: "High Risk",
                        value: "\(autoPermission.activeGrants.filter { $0.permission.riskLevel == .high || $0.permission.riskLevel == .critical }.count)",
                        icon: "exclamationmark.triangle.fill",
                        color: .red
                    )
                }
                
                // Recent activity
                StatusCard(
                    title: "Recent Activity",
                    icon: "clock.arrow.circlepath",
                    color: .blue
                ) {
                    if autoPermission.activeGrants.isEmpty {
                        Text("No recent permission grants")
                            .foregroundColor(.secondary)
                            .padding(.vertical, 8)
                    } else {
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(autoPermission.activeGrants.prefix(5), id: \.id) { grant in
                                HStack {
                                    Image(systemName: riskIcon(for: grant.permission.riskLevel))
                                        .foregroundColor(riskColor(for: grant.permission.riskLevel))
                                    Text(grant.permission.description)
                                    Spacer()
                                    Text(RelativeDateTimeFormatter().localizedString(for: grant.grantedAt, relativeTo: Date()))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    // MARK: - Configuration View
    
    private var configurationView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Unattended mode configuration
                ConfigSection(title: "Unattended Mode", icon: "cpu") {
                    Toggle("Enable Unattended Execution", isOn: $autoPermission.configuration.unattendedMode)
                    
                    if autoPermission.configuration.unattendedMode {
                        VStack(alignment: .leading, spacing: 12) {
                            Toggle("Auto-grant Developer Tools", isOn: .constant(autoPermission.configuration.unattendedConfig?.autoGrantDeveloperTools ?? false))
                            Toggle("Enable Sudo Passthrough", isOn: .constant(autoPermission.configuration.unattendedConfig?.enableSudoPassthrough ?? false))
                            Toggle("Auto-grant File System Access", isOn: .constant(autoPermission.configuration.unattendedConfig?.autoGrantFileSystem ?? false))
                            
                            HStack {
                                Text("Session Timeout:")
                                TextField("Minutes", value: .constant(60), format: .number)
                                    .textFieldStyle(.roundedBorder)
                                    .frame(width: 80)
                                Text("minutes")
                            }
                        }
                        .padding(.leading, 20)
                    }
                }
                
                // Security configuration
                ConfigSection(title: "Security", icon: "lock") {
                    Toggle("Enable Audit Logging", isOn: $autoPermission.configuration.auditingEnabled)
                    
                    HStack {
                        Text("Credential Timeout:")
                        TextField("Seconds", value: $autoPermission.configuration.credentialTimeout, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 100)
                        Text("seconds")
                    }
                    
                    Button("Manage Credentials...") {
                        showingCredentialSheet = true
                    }
                    
                    Button("Edit Policies...") {
                        showingPolicyEditor = true
                    }
                }
                
                // Import/Export
                ConfigSection(title: "Configuration Management", icon: "square.and.arrow.down") {
                    HStack {
                        Button("Export Configuration") {
                            Task { await exportConfiguration() }
                        }
                        
                        Button("Import Configuration") {
                            importConfiguration()
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    // MARK: - Active Grants View
    
    private var activeGrantsView: some View {
        VStack(spacing: 0) {
            // Toolbar
            HStack {
                Text("\(autoPermission.activeGrants.count) Active Grants")
                    .font(.headline)
                
                Spacer()
                
                Button("Revoke All") {
                    Task { await revokeAllGrants() }
                }
                .disabled(autoPermission.activeGrants.isEmpty)
            }
            .padding()
            .background(Color(NSColor.windowBackgroundColor))
            
            // Grants list
            if autoPermission.activeGrants.isEmpty {
                VStack {
                    Image(systemName: "checkmark.shield")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text("No active permission grants")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(autoPermission.activeGrants, id: \.id) { grant in
                        GrantRow(grant: grant) {
                            Task {
                                await autoPermission.revokeGrant(grant.id)
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Audit Log View
    
    private var auditLogView: some View {
        AuditLogView(autoPermission: autoPermission)
    }
    
    // MARK: - Testing View
    
    private var testingView: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Permission Testing")
                .font(.title2)
                .padding(.horizontal)
            
            // Test command input
            VStack(alignment: .leading, spacing: 8) {
                Text("Test Command:")
                    .font(.headline)
                
                HStack {
                    TextField("Enter command to test permissions...", text: $testCommand)
                        .textFieldStyle(.roundedBorder)
                    
                    Button("Execute") {
                        Task { await executeTest() }
                    }
                    .disabled(testCommand.isEmpty || !autoPermission.isActive)
                }
                
                Text("Example: sudo echo 'test' > /tmp/test.txt")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            
            // Test result
            if let result = testResult {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Execution Result")
                        .font(.headline)
                    
                    // Granted permissions
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Granted Permissions:")
                            .font(.subheadline)
                        ForEach(result.grantedPermissions, id: \.id) { grant in
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text(grant.permission.description)
                                Spacer()
                                Text(grant.scope.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(8)
                    
                    // Output
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Output:")
                                .font(.subheadline)
                            Spacer()
                            Text("Exit Code: \(result.exitCode)")
                                .font(.caption)
                                .foregroundColor(result.exitCode == 0 ? .green : .red)
                        }
                        
                        ScrollView {
                            Text(result.output)
                                .font(.system(.body, design: .monospaced))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .frame(height: 200)
                        .padding(8)
                        .background(Color.black.opacity(0.05))
                        .cornerRadius(4)
                    }
                    
                    Text("Execution time: \(String(format: "%.2f", result.executionTime))s")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
            }
            
            Spacer()
        }
        .padding(.vertical)
    }
    
    // MARK: - Helper Methods
    
    private func riskIcon(for level: RiskLevel) -> String {
        switch level {
        case .low: return "checkmark.circle"
        case .medium: return "exclamationmark.circle"
        case .high: return "exclamationmark.triangle"
        case .critical: return "xmark.octagon"
        }
    }
    
    private func riskColor(for level: RiskLevel) -> Color {
        switch level {
        case .low: return .green
        case .medium: return .orange
        case .high: return .red
        case .critical: return .purple
        }
    }
    
    private func exportConfiguration() async {
        do {
            let data = try await autoPermission.exportConfiguration()
            
            let savePanel = NSSavePanel()
            savePanel.allowedContentTypes = [.json]
            savePanel.nameFieldStringValue = "auto-permission-config.json"
            
            if savePanel.runModal() == .OK, let url = savePanel.url {
                try data.write(to: url)
            }
        } catch {
            print("Export failed: \(error)")
        }
    }
    
    private func importConfiguration() {
        let openPanel = NSOpenPanel()
        openPanel.allowedContentTypes = [.json]
        openPanel.allowsMultipleSelection = false
        
        if openPanel.runModal() == .OK, let url = openPanel.url {
            Task {
                do {
                    let data = try Data(contentsOf: url)
                    try await autoPermission.importConfiguration(data)
                } catch {
                    print("Import failed: \(error)")
                }
            }
        }
    }
    
    private func revokeAllGrants() async {
        for grant in autoPermission.activeGrants {
            await autoPermission.revokeGrant(grant.id)
        }
    }
    
    private func executeTest() async {
        do {
            testResult = try await autoPermission.executeWithPermissions(testCommand)
        } catch {
            print("Test execution failed: \(error)")
        }
    }
}

// MARK: - Supporting Views

struct TabButton: View {
    let title: String
    let icon: String
    let id: String
    @Binding var selection: String
    
    var body: some View {
        Button(action: { selection = id }) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title3)
                Text(title)
                    .font(.caption)
            }
            .foregroundColor(selection == id ? .accentColor : .secondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
        .background(selection == id ? Color.accentColor.opacity(0.1) : Color.clear)
    }
}

struct StatusCard<Content: View>: View {
    let title: String
    let icon: String
    let color: Color
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.headline)
            }
            
            content()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
}

struct StatusRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label + ":")
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Spacer()
            }
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
}

struct ConfigSection<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                Text(title)
                    .font(.headline)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                content()
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(8)
        }
    }
}

struct GrantRow: View {
    let grant: PermissionGrant
    let onRevoke: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: riskIcon(for: grant.permission.riskLevel))
                .foregroundColor(riskColor(for: grant.permission.riskLevel))
            
            VStack(alignment: .leading) {
                Text(grant.permission.description)
                    .font(.headline)
                Text("Scope: \(grant.scope.description)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(RelativeDateTimeFormatter().localizedString(for: grant.grantedAt, relativeTo: Date()))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if grant.isExpired {
                    Text("Expired")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            
            Button("Revoke") {
                onRevoke()
            }
            .buttonStyle(.borderless)
        }
        .padding(.vertical, 4)
    }
    
    private func riskIcon(for level: RiskLevel) -> String {
        switch level {
        case .low: return "checkmark.circle"
        case .medium: return "exclamationmark.circle"
        case .high: return "exclamationmark.triangle"
        case .critical: return "xmark.octagon"
        }
    }
    
    private func riskColor(for level: RiskLevel) -> Color {
        switch level {
        case .low: return .green
        case .medium: return .orange
        case .high: return .red
        case .critical: return .purple
        }
    }
}

// MARK: - Audit Log View

struct AuditLogView: View {
    @ObservedObject var autoPermission: AutoPermissionSystem
    @State private var entries: [AuditEntry] = []
    @State private var filter = AuditFilter()
    @State private var searchText = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Toolbar
            HStack {
                Text("Audit Log")
                    .font(.headline)
                
                Spacer()
                
                // Search
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Search...", text: $searchText)
                        .textFieldStyle(.plain)
                }
                .padding(4)
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(4)
                .frame(width: 200)
                
                // Refresh
                Button(action: { Task { await loadEntries() } }) {
                    Image(systemName: "arrow.clockwise")
                }
            }
            .padding()
            .background(Color(NSColor.windowBackgroundColor))
            
            // Entries list
            if entries.isEmpty {
                VStack {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text("No audit entries")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(filteredEntries, id: \.id) { entry in
                        AuditEntryRow(entry: entry)
                    }
                }
            }
        }
        .task {
            await loadEntries()
        }
    }
    
    private var filteredEntries: [AuditEntry] {
        if searchText.isEmpty {
            return entries
        }
        
        return entries.filter { entry in
            // Search in various fields
            if let permission = entry.permission, permission.localizedCaseInsensitiveContains(searchText) {
                return true
            }
            if let command = entry.command, command.localizedCaseInsensitiveContains(searchText) {
                return true
            }
            if let actor = entry.actor, actor.localizedCaseInsensitiveContains(searchText) {
                return true
            }
            return false
        }
    }
    
    private func loadEntries() async {
        entries = await autoPermission.getAuditLog(filter: filter)
    }
}

struct AuditEntryRow: View {
    let entry: AuditEntry
    
    var body: some View {
        HStack {
            Image(systemName: auditIcon(for: entry.type))
                .foregroundColor(auditColor(for: entry.type))
            
            VStack(alignment: .leading) {
                Text(auditTitle(for: entry))
                    .font(.headline)
                Text(auditDetails(for: entry))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(entry.timestamp, style: .relative)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
    
    private func auditIcon(for type: AuditType) -> String {
        switch type {
        case .grant: return "key.fill"
        case .revoke: return "key.slash"
        case .execution: return "terminal"
        case .credential: return "lock.fill"
        case .policy: return "shield"
        }
    }
    
    private func auditColor(for type: AuditType) -> Color {
        switch type {
        case .grant: return .green
        case .revoke: return .orange
        case .execution: return .blue
        case .credential: return .purple
        case .policy: return .gray
        }
    }
    
    private func auditTitle(for entry: AuditEntry) -> String {
        switch entry.type {
        case .grant:
            return "Permission Granted: \(entry.permission ?? "Unknown")"
        case .revoke:
            return "Permission Revoked: \(entry.permission ?? "Unknown")"
        case .execution:
            return "Command Executed"
        case .credential:
            return "Credential \(entry.operation?.rawValue.capitalized ?? "Operation")"
        case .policy:
            return "Policy Change"
        }
    }
    
    private func auditDetails(for entry: AuditEntry) -> String {
        switch entry.type {
        case .grant, .revoke:
            return "Scope: \(entry.scope ?? "Unknown") • Actor: \(entry.actor ?? "System")"
        case .execution:
            let cmd = entry.command ?? "Unknown command"
            let shortCmd = cmd.count > 50 ? String(cmd.prefix(50)) + "..." : cmd
            return "\(shortCmd) • Exit: \(entry.exitCode ?? -1)"
        case .credential:
            return "ID: \(entry.identifier ?? "Unknown") • Actor: \(entry.actor ?? "System")"
        case .policy:
            return "Actor: \(entry.actor ?? "System")"
        }
    }
}

// MARK: - Credential Management View

struct CredentialManagementView: View {
    @ObservedObject var autoPermission: AutoPermissionSystem
    @Environment(\.dismiss) var dismiss
    
    @State private var credentials: [(String, CredentialType)] = []
    @State private var showingAddCredential = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Credential Management")
                    .font(.title2)
                
                Spacer()
                
                Button("Done") {
                    dismiss()
                }
            }
            .padding()
            
            // Credential list
            List {
                ForEach(credentials, id: \.0) { credential in
                    HStack {
                        Image(systemName: credentialIcon(for: credential.1))
                        Text(credential.0)
                        Spacer()
                        Text(credential.1.rawValue.capitalized)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Button(action: {
                            Task {
                                try await autoPermission.removeCredential(credential.0)
                                loadCredentials()
                            }
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                        .buttonStyle(.borderless)
                    }
                }
            }
            
            // Add button
            HStack {
                Button("Add Credential...") {
                    showingAddCredential = true
                }
                Spacer()
            }
            .padding()
        }
        .frame(width: 500, height: 400)
        .onAppear {
            loadCredentials()
        }
    }
    
    private func credentialIcon(for type: CredentialType) -> String {
        switch type {
        case .password: return "key.fill"
        case .token: return "ticket.fill"
        case .certificate: return "doc.badge.gearshape"
        case .key: return "lock.fill"
        }
    }
    
    private func loadCredentials() {
        // In production, would load from secure storage
        credentials = [
            ("sudo", .password),
            ("github_token", .token)
        ]
    }
}

// MARK: - Policy Editor View

struct PolicyEditorView: View {
    @ObservedObject var autoPermission: AutoPermissionSystem
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            Text("Policy Editor")
                .font(.title2)
                .padding()
            
            Text("Policy configuration interface would go here")
                .foregroundColor(.secondary)
                .padding()
            
            Spacer()
            
            Button("Done") {
                dismiss()
            }
            .padding()
        }
        .frame(width: 600, height: 500)
    }
}