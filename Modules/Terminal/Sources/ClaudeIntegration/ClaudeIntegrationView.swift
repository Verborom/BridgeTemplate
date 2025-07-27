import SwiftUI

/// # Claude Integration View
///
/// The main UI for Claude Code integration within the Terminal module.
/// Provides visual feedback for onboarding, session management, and
/// intelligent command assistance.
///
/// ## Overview
///
/// This view presents:
/// - Onboarding progress and status
/// - Current session information
/// - Mastery level indicators
/// - Command suggestions
/// - Session history
///
/// ## Topics
///
/// ### Main Views
/// - ``ClaudeIntegrationView``
/// - ``OnboardingProgressView``
/// - ``SessionStatusView``
/// - ``CommandSuggestionsView``
public struct ClaudeIntegrationView: View {
    
    /// Claude integration instance
    @ObservedObject var integration: ClaudeCodeIntegration
    
    /// Show onboarding sheet
    @State private var showOnboarding = false
    
    /// Show session details
    @State private var showSessionDetails = false
    
    public init(integration: ClaudeCodeIntegration) {
        self.integration = integration
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView
            
            // Main content
            switch integration.status {
            case .inactive:
                inactiveView
            case .awaitingSession:
                awaitingSessionView
            case .onboarding:
                OnboardingProgressView(integration: integration)
            case .ready:
                readyView
            case .error(let message):
                errorView(message)
            }
        }
        .sheet(isPresented: $showOnboarding) {
            OnboardingWizardView(integration: integration)
        }
        .sheet(isPresented: $showSessionDetails) {
            SessionDetailsView(session: integration.currentSession)
        }
    }
    
    /// Header view with status
    private var headerView: some View {
        HStack {
            Image(systemName: "brain")
                .font(.title2)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.purple, .blue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            VStack(alignment: .leading) {
                Text("Claude Code Integration")
                    .font(.headline)
                Text(statusText)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if integration.currentSession != nil {
                Button(action: { showSessionDetails = true }) {
                    Image(systemName: "info.circle")
                        .foregroundColor(.blue)
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    /// Status text based on integration state
    private var statusText: String {
        switch integration.status {
        case .inactive:
            return "Not initialized"
        case .awaitingSession:
            return "Ready to start"
        case .onboarding:
            return "Onboarding in progress..."
        case .ready:
            if let session = integration.currentSession {
                return "Active - Mastery: \(session.masteryLevel.rawValue)"
            }
            return "Ready"
        case .error(let message):
            return "Error: \(message)"
        }
    }
    
    /// Inactive state view
    private var inactiveView: some View {
        VStack(spacing: 20) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 64))
                .foregroundColor(.gray)
            
            Text("Claude Integration Inactive")
                .font(.title2)
                .foregroundColor(.gray)
            
            Button("Initialize Integration") {
                Task {
                    try await integration.initialize()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    /// Awaiting session view
    private var awaitingSessionView: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.crop.circle.badge.plus")
                .font(.system(size: 64))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.purple, .blue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text("Start Claude Code Session")
                .font(.title2)
            
            Text("Begin automated onboarding to achieve repository mastery")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Start Onboarding") {
                showOnboarding = true
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    /// Ready state view
    private var readyView: some View {
        VStack(spacing: 0) {
            if let session = integration.currentSession {
                // Session info bar
                SessionStatusBar(session: session)
                
                Divider()
                
                // Main content
                HSplitView {
                    // Command suggestions
                    CommandSuggestionsView(integration: integration)
                        .frame(minWidth: 200, idealWidth: 300)
                    
                    // Session activity
                    SessionActivityView(session: session)
                }
            }
        }
    }
    
    /// Error view
    private func errorView(_ message: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 64))
                .foregroundColor(.red)
            
            Text("Integration Error")
                .font(.title2)
                .foregroundColor(.red)
            
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Retry") {
                Task {
                    try await integration.initialize()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

/// # Onboarding Progress View
///
/// Shows real-time progress during automated onboarding.
public struct OnboardingProgressView: View {
    
    @ObservedObject var integration: ClaudeCodeIntegration
    
    public var body: some View {
        VStack(spacing: 30) {
            // Progress indicator
            ProgressView(value: integration.currentSession?.metadata.onboardingProgress ?? 0)
                .progressViewStyle(.linear)
                .frame(width: 400)
            
            // Current step
            VStack(spacing: 8) {
                Text("Executing Onboarding")
                    .font(.title2)
                
                if let progress = integration.currentSession?.metadata.onboardingProgress {
                    Text("\(Int(progress * 100))% Complete")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
            }
            
            // Step list
            VStack(alignment: .leading, spacing: 12) {
                OnboardingStepRow(step: "Repository Access", status: .completed)
                OnboardingStepRow(step: "Master Documentation", status: .completed)
                OnboardingStepRow(step: "Critical Documents", status: .inProgress)
                OnboardingStepRow(step: "Source Code Analysis", status: .pending)
                OnboardingStepRow(step: "Build System", status: .pending)
                OnboardingStepRow(step: "Automation Review", status: .pending)
                OnboardingStepRow(step: "Final Verification", status: .pending)
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

/// # Session Status Bar
///
/// Displays current session information and mastery level.
struct SessionStatusBar: View {
    let session: ClaudeSession
    
    var body: some View {
        HStack {
            // Session ID
            Label(session.id.prefix(8) + "...", systemImage: "tag")
                .font(.caption)
            
            Divider()
                .frame(height: 20)
            
            // Mastery level
            MasteryLevelBadge(level: session.masteryLevel)
            
            Divider()
                .frame(height: 20)
            
            // Command count
            Label("\(session.commandHistory.count) commands", systemImage: "terminal")
                .font(.caption)
            
            Spacer()
            
            // Session time
            Text("Active for \(session.createdAt.timeIntervalSinceNow.formatted())")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(NSColor.controlBackgroundColor))
    }
}

/// # Command Suggestions View
///
/// Shows intelligent command suggestions based on context.
public struct CommandSuggestionsView: View {
    
    @ObservedObject var integration: ClaudeCodeIntegration
    @State private var suggestions: [Suggestion] = []
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text("Suggestions")
                    .font(.headline)
                Spacer()
                Button(action: refreshSuggestions) {
                    Image(systemName: "arrow.clockwise")
                        .font(.caption)
                }
                .buttonStyle(.plain)
            }
            
            // Suggestions list
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(suggestions, id: \.title) { suggestion in
                        SuggestionCard(
                            suggestion: suggestion,
                            onExecute: {
                                Task {
                                    try await integration.executeCommand(suggestion.command)
                                }
                            }
                        )
                    }
                }
            }
        }
        .padding()
        .onAppear {
            refreshSuggestions()
        }
    }
    
    private func refreshSuggestions() {
        Task {
            suggestions = await integration.getSuggestions()
        }
    }
}

/// # Session Activity View
///
/// Shows command history and session activity.
struct SessionActivityView: View {
    let session: ClaudeSession
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Session Activity")
                .font(.headline)
                .padding(.horizontal)
                .padding(.top)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(session.commandHistory.reversed(), id: \.command) { entry in
                        CommandHistoryRow(entry: entry)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - Supporting Views

/// Onboarding wizard view
struct OnboardingWizardView: View {
    @ObservedObject var integration: ClaudeCodeIntegration
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 30) {
            // Header
            VStack(spacing: 12) {
                Image(systemName: "brain")
                    .font(.system(size: 48))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.purple, .blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                Text("Claude Code Onboarding")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Achieve complete mastery of the Bridge Template repository")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            
            // Benefits
            VStack(alignment: .leading, spacing: 16) {
                OnboardingBenefit(
                    icon: "doc.text.magnifyingglass",
                    title: "Complete Documentation Reading",
                    description: "All critical documents will be processed"
                )
                OnboardingBenefit(
                    icon: "folder.badge.gearshape",
                    title: "Repository Structure Mastery",
                    description: "Full understanding of project organization"
                )
                OnboardingBenefit(
                    icon: "hammer.fill",
                    title: "Build System Expertise",
                    description: "Master the granular development system"
                )
                OnboardingBenefit(
                    icon: "checkmark.seal.fill",
                    title: "Verified Mastery",
                    description: "Confirmation of repository expertise"
                )
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(12)
            
            // Actions
            HStack(spacing: 16) {
                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle(.bordered)
                
                Button("Start Onboarding") {
                    Task {
                        dismiss()
                        _ = try await integration.startOnboarding()
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
        }
        .padding(40)
        .frame(width: 600)
    }
}

/// Session details view
struct SessionDetailsView: View {
    let session: ClaudeSession?
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack {
                Text("Session Details")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Button("Done") {
                    dismiss()
                }
            }
            
            if let session = session {
                // Session info
                GroupBox("Session Information") {
                    VStack(alignment: .leading, spacing: 12) {
                        DetailRow(label: "Session ID", value: session.id)
                        DetailRow(label: "Created", value: session.createdAt.formatted())
                        DetailRow(label: "Mastery Level", value: session.masteryLevel.rawValue)
                        DetailRow(label: "Commands Executed", value: "\(session.commandHistory.count)")
                    }
                    .padding(.vertical, 8)
                }
                
                // Repository knowledge
                GroupBox("Repository Knowledge") {
                    VStack(alignment: .leading, spacing: 8) {
                        KnowledgeRow(
                            label: "Complete Structure",
                            status: session.workingContext.repositoryKnowledge.hasCompleteStructure
                        )
                        KnowledgeRow(
                            label: "Core Systems",
                            status: session.workingContext.repositoryKnowledge.coreSystemsUnderstood
                        )
                        KnowledgeRow(
                            label: "Build System",
                            status: session.workingContext.repositoryKnowledge.buildSystemMastered
                        )
                        KnowledgeRow(
                            label: "Automation",
                            status: session.workingContext.repositoryKnowledge.automationUnderstood
                        )
                        KnowledgeRow(
                            label: "Configuration",
                            status: session.workingContext.repositoryKnowledge.configurationKnown
                        )
                        KnowledgeRow(
                            label: "Granular Build",
                            status: session.workingContext.repositoryKnowledge.granularBuildVerified
                        )
                    }
                    .padding(.vertical, 8)
                }
                
                Spacer()
            }
        }
        .padding(30)
        .frame(width: 500, height: 600)
    }
}

// MARK: - Component Views

struct OnboardingStepRow: View {
    let step: String
    let status: StepStatus
    
    enum StepStatus {
        case pending, inProgress, completed
    }
    
    var body: some View {
        HStack {
            Image(systemName: statusIcon)
                .foregroundColor(statusColor)
                .frame(width: 20)
            
            Text(step)
                .foregroundColor(status == .pending ? .secondary : .primary)
            
            Spacer()
        }
    }
    
    private var statusIcon: String {
        switch status {
        case .pending: return "circle"
        case .inProgress: return "circle.dotted"
        case .completed: return "checkmark.circle.fill"
        }
    }
    
    private var statusColor: Color {
        switch status {
        case .pending: return .gray
        case .inProgress: return .blue
        case .completed: return .green
        }
    }
}

struct MasteryLevelBadge: View {
    let level: MasteryLevel
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
            Text(level.rawValue)
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.2))
        .foregroundColor(color)
        .cornerRadius(12)
    }
    
    private var icon: String {
        switch level {
        case .none: return "xmark.circle"
        case .basic: return "star"
        case .intermediate: return "star.leadinghalf.filled"
        case .expert: return "star.fill"
        }
    }
    
    private var color: Color {
        switch level {
        case .none: return .gray
        case .basic: return .blue
        case .intermediate: return .purple
        case .expert: return .green
        }
    }
}

struct SuggestionCard: View {
    let suggestion: Suggestion
    let onExecute: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(suggestion.title)
                .font(.headline)
            
            Text(suggestion.reason)
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack {
                Text(suggestion.command)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(.blue)
                    .lineLimit(1)
                
                Spacer()
                
                Button("Run") {
                    onExecute()
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
}

struct CommandHistoryRow: View {
    let entry: CommandEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: entry.result.success ? "checkmark.circle" : "xmark.circle")
                    .foregroundColor(entry.result.success ? .green : .red)
                    .font(.caption)
                
                Text(entry.command)
                    .font(.system(.body, design: .monospaced))
                    .lineLimit(1)
                
                Spacer()
                
                Text(entry.timestamp.formatted(.relative(presentation: .abbreviated)))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if !entry.result.output.isEmpty {
                Text(entry.result.output)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
        .cornerRadius(6)
    }
}

struct OnboardingBenefit: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

struct KnowledgeRow: View {
    let label: String
    let status: Bool
    
    var body: some View {
        HStack {
            Image(systemName: status ? "checkmark.circle.fill" : "circle")
                .foregroundColor(status ? .green : .gray)
                .font(.caption)
            
            Text(label)
                .font(.body)
            
            Spacer()
        }
    }
}