import SwiftUI

@main
struct BridgeMacApp: App {
    @StateObject private var appModel = AppModel()
    
    var body: some Scene {
        WindowGroup {
            MainWindow()
                .environmentObject(appModel)
        }
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified)
        
        Settings {
            SettingsView()
                .environmentObject(appModel)
        }
    }
}

// MARK: - App Model
class AppModel: ObservableObject {
    @Published var selectedModule: String = "Dashboard"
    @Published var modules: [Module] = Module.defaultModules
}

// MARK: - Module Definition
struct Module: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let color: Color
    
    static let defaultModules = [
        Module(name: "Dashboard", icon: "square.grid.2x2", color: .blue),
        Module(name: "Projects", icon: "folder", color: .green),
        Module(name: "Terminal", icon: "terminal", color: .orange),
        Module(name: "Settings", icon: "gear", color: .gray)
    ]
}