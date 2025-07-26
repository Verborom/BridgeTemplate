import SwiftUI

struct DashboardView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                Text("Dashboard")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                // Stats Grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    StatCard(title: "Projects", value: "12", icon: "folder.fill", color: .blue)
                    StatCard(title: "Active", value: "3", icon: "play.circle.fill", color: .green)
                    StatCard(title: "Completed", value: "9", icon: "checkmark.circle.fill", color: .purple)
                    StatCard(title: "Storage", value: "2.4 GB", icon: "externaldrive.fill", color: .orange)
                }
                
                // Recent Activity
                VStack(alignment: .leading, spacing: 10) {
                    Text("Recent Activity")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    ForEach(0..<3) { index in
                        ActivityRow(
                            title: "Project \(index + 1)",
                            subtitle: "Updated \(index + 1) hours ago",
                            icon: "doc.fill"
                        )
                    }
                }
                
                Spacer()
            }
            .padding()
        }
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                Spacer()
            }
            
            Text(value)
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

// MARK: - Activity Row
struct ActivityRow: View {
    let title: String
    let subtitle: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
    }
}