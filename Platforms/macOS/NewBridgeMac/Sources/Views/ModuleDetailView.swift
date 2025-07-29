/// # ModuleDetailView
///
/// Displays the content of a selected module, showcasing the UniversalTemplate
/// system and infinite nesting architecture.
///
/// ## Overview
///
/// This view demonstrates how the architectural rebuild handles different module types:
/// - Template-generated modules with automatic submodule hierarchies
/// - Real implementations with sophisticated functionality (Terminal)
/// - Seamless integration between different architecture approaches
///
/// ## Topics
/// ### Display Components
/// - Module content rendering
/// - Submodule navigation
/// - Status and metadata display
import SwiftUI
import BridgeCore

struct ModuleDetailView: View {
    let module: any BridgeModule
    
    var body: some View {
        VStack(spacing: 0) {
            // Module header
            moduleHeader
            
            Divider()
            
            // Module content
            ScrollView {
                module.view
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationTitle(module.displayName)
        .navigationSubtitle("v\(module.version)")
    }
    
    /// Module header with metadata
    private var moduleHeader: some View {
        HStack {
            // Module icon and info
            HStack {
                Image(systemName: module.icon)
                    .font(.title)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.accentColor, .blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                VStack(alignment: .leading) {
                    Text(module.displayName)
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    HStack {
                        Text("Version \(module.version)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if module.id == "com.bridge.terminal" {
                            Text("• Real Implementation")
                                .font(.caption)
                                .foregroundColor(.green)
                        } else {
                            Text("• Template Generated")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            
            Spacer()
            
            // Module actions
            HStack {
                Button(action: {}) {
                    Image(systemName: "arrow.clockwise")
                }
                .help("Refresh module")
                
                Button(action: {}) {
                    Image(systemName: "gear")
                }
                .help("Module settings")
            }
        }
        .padding()
        .background(.regularMaterial)
    }
}