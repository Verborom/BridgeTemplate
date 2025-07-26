import SwiftUI

struct MainWindow: View {
    @EnvironmentObject var appModel: AppModel
    
    var body: some View {
        NavigationSplitView {
            // Sidebar
            SidebarView()
                .navigationSplitViewColumnWidth(min: 200, ideal: 250, max: 300)
        } detail: {
            // Content
            ContentRouter()
        }
    }
}

// MARK: - Sidebar
struct SidebarView: View {
    @EnvironmentObject var appModel: AppModel
    
    var body: some View {
        List(selection: $appModel.selectedModule) {
            Section("Modules") {
                ForEach(appModel.modules) { module in
                    Label {
                        Text(module.name)
                    } icon: {
                        Image(systemName: module.icon)
                            .foregroundColor(module.color)
                    }
                    .tag(module.name)
                }
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("Bridge")
    }
}

// MARK: - Content Router
struct ContentRouter: View {
    @EnvironmentObject var appModel: AppModel
    
    var body: some View {
        switch appModel.selectedModule {
        case "Dashboard":
            DashboardView()
        case "Projects":
            ProjectsView()
        case "Terminal":
            TerminalView()
        case "Settings":
            SettingsView()
        default:
            EmptyView()
        }
    }
}