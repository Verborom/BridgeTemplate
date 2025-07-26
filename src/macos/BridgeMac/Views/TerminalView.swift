import SwiftUI

struct TerminalView: View {
    @State private var output = "Welcome to Bridge Terminal\n$ "
    @State private var currentCommand = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Terminal Header
            HStack {
                Text("Terminal")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: clearTerminal) {
                    Label("Clear", systemImage: "trash")
                }
                .buttonStyle(.plain)
            }
            .padding()
            .background(Color.black.opacity(0.05))
            
            // Terminal Output
            ScrollView {
                Text(output)
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.green)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
            .background(Color.black.opacity(0.9))
            
            // Command Input
            HStack {
                Text("$")
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.green)
                
                TextField("Enter command...", text: $currentCommand)
                    .textFieldStyle(.plain)
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.white)
                    .onSubmit {
                        executeCommand()
                    }
            }
            .padding()
            .background(Color.black.opacity(0.8))
        }
    }
    
    func executeCommand() {
        guard !currentCommand.isEmpty else { return }
        
        output += currentCommand + "\n"
        
        // Simple command responses
        switch currentCommand.lowercased() {
        case "help":
            output += "Available commands: help, clear, date, echo <text>\n"
        case "clear":
            clearTerminal()
            return
        case "date":
            output += "\(Date())\n"
        default:
            if currentCommand.starts(with: "echo ") {
                let text = String(currentCommand.dropFirst(5))
                output += text + "\n"
            } else {
                output += "Command not found: \(currentCommand)\n"
            }
        }
        
        output += "$ "
        currentCommand = ""
    }
    
    func clearTerminal() {
        output = "Terminal cleared\n$ "
        currentCommand = ""
    }
}