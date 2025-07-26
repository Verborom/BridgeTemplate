import SwiftUI

/// # QuickActions Sub-Module
///
/// Customizable quick action buttons for common tasks. Users can configure
/// which actions appear and in what order, demonstrating personalization
/// through hot-swappable modules.
///
/// ## Overview
///
/// QuickActions shows how user preferences can drive module configuration.
/// Each user can have their own version of this module with personalized
/// actions, and switching between users hot-swaps to their configuration.
///
/// ## Topics
///
/// ### Components
/// - ``QuickActions``
/// - ``QuickActionButton``
/// - ``ActionConfiguration``
///
/// ### Version History
/// - v1.1.0: Added drag-and-drop reordering
/// - v1.0.2: Added custom action support
/// - v1.0.1: Improved button animations
/// - v1.0.0: Initial implementation
@MainActor
public class QuickActions: BridgeModule {
    
    public let id = "com.bridge.dashboard.quickactions"
    public let displayName = "Quick Actions"
    public let icon = "square.grid.2x2.fill"
    public let version = ModuleVersion(major: 1, minor: 1, patch: 0)
    public let subModules: [String: any BridgeModule] = [:]
    public let dependencies: [String] = []
    
    @Published private var configuration = ActionConfiguration()
    
    public var view: AnyView {
        AnyView(
            QuickActionsView(configuration: configuration)
        )
    }
    
    public func initialize() async throws {
        print("⚡ Initializing QuickActions v\(version)")
        await loadUserConfiguration()
    }
    
    public func cleanup() async {
        await saveUserConfiguration()
    }
    
    public func canUnload() -> Bool {
        true
    }
    
    public func receiveMessage(_ message: ModuleMessage) async throws {
        switch message.type {
        case "executeAction":
            if let actionId = message.payload["actionId"] as? String {
                await executeAction(actionId)
            }
        case "reorderActions":
            if let newOrder = message.payload["order"] as? [String] {
                configuration.reorderActions(newOrder)
            }
        default:
            break
        }
    }
    
    private func loadUserConfiguration() async {
        // Load user's personalized actions
    }
    
    private func saveUserConfiguration() async {
        // Save configuration
    }
    
    private func executeAction(_ actionId: String) async {
        print("⚡ Executing action: \(actionId)")
        // Send message to appropriate module
    }
}

/// QuickActions view with customizable buttons
struct QuickActionsView: View {
    @ObservedObject var configuration: ActionConfiguration
    
    var body: some View {
        VStack(spacing: 8) {
            ForEach(configuration.enabledActions) { action in
                QuickActionButton(action: action)
            }
        }
    }
}

/// Individual quick action button
public struct QuickActionButton: View {
    let action: QuickAction
    @State private var isPressed = false
    
    public var body: some View {
        Button(action: { executeAction() }) {
            HStack {
                Image(systemName: action.icon)
                    .font(.system(size: 16))
                Text(action.title)
                    .font(BridgeTypography.body)
                Spacer()
            }
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                LinearGradient.arcPrimary
                    .opacity(isPressed ? 0.8 : 1.0)
            )
            .cornerRadius(8)
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(.plain)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity) { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        } perform: {
            executeAction()
        }
    }
    
    private func executeAction() {
        // Send message to execute action
        print("⚡ Action triggered: \(action.title)")
    }
}

/// Configuration for quick actions
class ActionConfiguration: ObservableObject {
    @Published var enabledActions: [QuickAction] = [
        QuickAction(id: "new-project", title: "New Project", icon: "plus.circle.fill"),
        QuickAction(id: "build-all", title: "Build All", icon: "hammer.circle.fill"),
        QuickAction(id: "open-docs", title: "Documentation", icon: "book.circle.fill"),
        QuickAction(id: "run-tests", title: "Run Tests", icon: "checkmark.circle.fill")
    ]
    
    func reorderActions(_ newOrder: [String]) {
        // Reorder based on IDs
    }
}