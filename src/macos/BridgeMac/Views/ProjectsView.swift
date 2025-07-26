import SwiftUI

struct ProjectsView: View {
    @State private var projects = Project.sampleProjects
    @State private var searchText = ""
    
    var body: some View {
        VStack {
            // Header
            HStack {
                Text("Projects")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: { addNewProject() }) {
                    Label("New Project", systemImage: "plus")
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            
            // Search
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Search projects...", text: $searchText)
                    .textFieldStyle(.plain)
            }
            .padding(8)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            .padding(.horizontal)
            
            // Projects List
            List(filteredProjects) { project in
                ProjectRow(project: project)
            }
            .listStyle(.inset)
        }
    }
    
    var filteredProjects: [Project] {
        if searchText.isEmpty {
            return projects
        } else {
            return projects.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    func addNewProject() {
        let newProject = Project(
            name: "New Project \(projects.count + 1)",
            description: "A new project created with Bridge",
            status: .active,
            createdDate: Date()
        )
        projects.append(newProject)
    }
}

// MARK: - Project Model
struct Project: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let status: Status
    let createdDate: Date
    
    enum Status: String {
        case active = "Active"
        case completed = "Completed"
        case archived = "Archived"
        
        var color: Color {
            switch self {
            case .active: return .green
            case .completed: return .blue
            case .archived: return .gray
            }
        }
    }
    
    static let sampleProjects = [
        Project(name: "Weather App", description: "Beautiful weather application", status: .active, createdDate: Date()),
        Project(name: "Todo List", description: "Task management tool", status: .completed, createdDate: Date()),
        Project(name: "Calculator", description: "Advanced calculator", status: .active, createdDate: Date())
    ]
}

// MARK: - Project Row
struct ProjectRow: View {
    let project: Project
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(project.name)
                    .font(.headline)
                Text(project.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(project.status.rawValue)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(project.status.color.opacity(0.2))
                .foregroundColor(project.status.color)
                .cornerRadius(4)
        }
        .padding(.vertical, 4)
    }
}