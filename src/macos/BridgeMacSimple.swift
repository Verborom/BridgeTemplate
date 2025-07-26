import SwiftUI

@main
struct BridgeMacApp: App {
    @StateObject private var appModel = AppModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appModel)
                .frame(minWidth: 800, minHeight: 600)
        }
    }
}

// MARK: - Models
class AppModel: ObservableObject {
    @Published var selectedTab = "Dashboard"
}

// MARK: - Main View
struct ContentView: View {
    @EnvironmentObject var appModel: AppModel
    
    var body: some View {
        NavigationSplitView {
            // Sidebar
            List(selection: $appModel.selectedTab) {
                Label("Dashboard", systemImage: "square.grid.2x2")
                    .tag("Dashboard")
                Label("Projects", systemImage: "folder")
                    .tag("Projects")
                Label("Terminal", systemImage: "terminal")
                    .tag("Terminal")
            }
            .listStyle(.sidebar)
            .navigationTitle("Bridge")
            .frame(minWidth: 200)
        } detail: {
            // Content
            switch appModel.selectedTab {
            case "Dashboard":
                DashboardView()
            case "Projects":
                ProjectsView()
            case "Terminal":
                TerminalView()
            default:
                Text("Select a module")
            }
        }
    }
}

// MARK: - Dashboard
struct DashboardView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Dashboard")
                .font(.largeTitle)
                .bold()
            
            HStack(spacing: 20) {
                StatCard(title: "Projects", value: "5", color: .blue)
                StatCard(title: "Active", value: "2", color: .green)
                StatCard(title: "Storage", value: "1.2 GB", color: .orange)
            }
            
            Text("Recent Activity")
                .font(.title2)
                .padding(.top)
            
            VStack(alignment: .leading, spacing: 10) {
                ActivityRow(text: "Project 1 updated")
                ActivityRow(text: "New build completed")
                ActivityRow(text: "Terminal session started")
            }
            
            Spacer()
        }
        .padding()
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(value)
                .font(.largeTitle)
                .bold()
            Text(title)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(color.opacity(0.1))
        .cornerRadius(10)
    }
}

struct ActivityRow: View {
    let text: String
    
    var body: some View {
        HStack {
            Image(systemName: "circle.fill")
                .foregroundColor(.blue)
                .font(.caption)
            Text(text)
            Spacer()
        }
        .padding(8)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(5)
    }
}

// MARK: - Projects
struct ProjectsView: View {
    @State private var projects = ["Weather App", "Todo List", "Calculator"]
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Projects")
                    .font(.largeTitle)
                    .bold()
                Spacer()
                Button("New Project", systemImage: "plus") {
                    projects.append("New Project \(projects.count + 1)")
                }
            }
            .padding()
            
            List(projects, id: \.self) { project in
                HStack {
                    Image(systemName: "folder")
                        .foregroundColor(.blue)
                    Text(project)
                    Spacer()
                    Text("Active")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.green.opacity(0.2))
                        .cornerRadius(4)
                }
                .padding(.vertical, 4)
            }
        }
    }
}

// MARK: - Terminal
struct TerminalView: View {
    @State private var output = "Bridge Terminal v1.0\n$ "
    @State private var command = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Output
            ScrollView {
                Text(output)
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.green)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
            .background(Color.black.opacity(0.9))
            
            // Input
            HStack {
                Text("$")
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.green)
                TextField("Enter command", text: $command)
                    .textFieldStyle(.plain)
                    .font(.system(.body, design: .monospaced))
                    .onSubmit {
                        output += command + "\n"
                        output += "Command executed: \(command)\n$ "
                        command = ""
                    }
            }
            .padding()
            .background(Color.black.opacity(0.8))
        }
    }
}