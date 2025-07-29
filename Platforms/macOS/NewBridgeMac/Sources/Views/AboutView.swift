/// # AboutView
///
/// Application information and architectural rebuild details.
import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            // App icon and title
            VStack(spacing: 12) {
                Image(systemName: "sparkles.rectangle.stack")
                    .font(.system(size: 48))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.purple, .blue, .cyan],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                Text("NewBridgeMac")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Version 3.0.0 (Architectural Rebuild)")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            
            // Description
            Text("Revolutionary modular development system with dynamic module loading, UniversalTemplate generation, and infinite nesting architecture.")
                .multilineTextAlignment(.center)
                .frame(maxWidth: 400)
            
            // Architecture info
            VStack(alignment: .leading, spacing: 8) {
                Text("Architectural Features:")
                    .font(.headline)
                
                Text("• Dynamic module discovery and loading")
                Text("• UniversalTemplate component generation")
                Text("• Hot-swappable architecture with zero downtime")
                Text("• Infinite nesting capabilities")
                Text("• Professional git workflow integration")
                Text("• Comprehensive Swift DocC documentation")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            // Close button
            Button("Close") {
                dismiss()
            }
            .keyboardShortcut(.escape)
        }
        .padding()
        .frame(width: 500, height: 400)
    }
}