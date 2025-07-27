import SwiftUI
import Terminal

/// Real Terminal Module that uses the actual Terminal implementation
@MainActor
class RealTerminalModule: BridgeModule, ObservableObject {
    let id = "com.bridge.terminal"
    let displayName = "Terminal"
    let icon = "terminal.fill"
    let version = ModuleVersion(major: 1, minor: 3, patch: 0)
    let dependencies: [String] = []
    let subModules: [String: any BridgeModule] = [:]
    
    // Real Terminal components - now with public initializers
    private let terminalViewModel = Terminal.TerminalViewModel()
    private let claudeIntegration = Terminal.ClaudeCodeIntegration()
    private let autoPermissionSystem = Terminal.AutoPermissionSystem()
    
    var view: AnyView {
        AnyView(
            Terminal.TerminalView(
                viewModel: terminalViewModel,
                claudeIntegration: claudeIntegration,
                autoPermissionSystem: autoPermissionSystem
            )
            .environmentObject(terminalViewModel)
        )
    }
    
    func initialize() async throws {
        print("🚀 Initializing REAL Terminal module v1.3.0...")
        
        // Initialize all components
        await terminalViewModel.loadConfiguration()
        await terminalViewModel.createNewSession()
        try await claudeIntegration.initialize()
        try await autoPermissionSystem.initialize()
        
        print("✅ REAL Terminal module v1.3.0 initialized with Claude Code integration and auto-permissions!")
    }
    
    func cleanup() async {
        await terminalViewModel.saveConfiguration()
        print("🧹 Real Terminal module cleaned up")
    }
    
    nonisolated func canUnload() -> Bool {
        return true
    }
    
    func receiveMessage(_ message: ModuleMessage) async throws {
        // Convert Core's ModuleMessage to Terminal's ModuleMessage
        let terminalMessage = Terminal.ModuleMessage(
            source: message.source,
            destination: message.destination,
            type: message.type,
            payload: message.payload
        )
        
        // Forward to actual terminal handling
        switch message.type {
        case "execute":
            if let command = message.payload["command"] {
                await terminalViewModel.activeSession?.execute(command)
            }
        case "createSession":
            await terminalViewModel.createNewSession()
        default:
            print("📨 Terminal received message: \(message.type)")
        }
    }
}