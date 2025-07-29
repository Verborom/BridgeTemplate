#!/usr/bin/env swift

import Foundation

// Quick test to check if NewBridgeMac is loading modules
print("🔍 Checking NewBridgeMac module loading...")

// Wait a moment for the app to start
Thread.sleep(forTimeInterval: 2)

// Check if app is running
let task = Process()
task.launchPath = "/bin/ps"
task.arguments = ["aux"]

let pipe = Pipe()
task.standardOutput = pipe
task.launch()
task.waitUntilExit()

let data = pipe.fileHandleForReading.readDataToEndOfFile()
let output = String(data: data, encoding: .utf8) ?? ""

if output.contains("NewBridgeMac") {
    print("✅ NewBridgeMac is running!")
    
    // Check console output
    print("\n📋 Console output (if any):")
    
    // Note: In a real scenario, we'd check system logs or app output
    // For now, just confirm app is running
    print("App is running. Check the UI to see if modules are loaded.")
    print("\nExpected modules:")
    print("  • Personal Assistant")
    print("  • Projects") 
    print("  • Documents")
    print("  • Settings")
    print("  • Terminal (v1.3.0)")
} else {
    print("❌ NewBridgeMac is not running")
}