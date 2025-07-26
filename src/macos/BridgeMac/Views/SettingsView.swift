import SwiftUI

struct SettingsView: View {
    @AppStorage("autoSave") private var autoSave = true
    @AppStorage("darkMode") private var darkMode = true
    @AppStorage("showLineNumbers") private var showLineNumbers = true
    
    var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem {
                    Label("General", systemImage: "gear")
                }
            
            AppearanceSettingsView()
                .tabItem {
                    Label("Appearance", systemImage: "paintbrush")
                }
            
            AdvancedSettingsView()
                .tabItem {
                    Label("Advanced", systemImage: "wrench")
                }
        }
        .frame(width: 500, height: 400)
    }
}

struct GeneralSettingsView: View {
    @AppStorage("autoSave") private var autoSave = true
    @AppStorage("autoBackup") private var autoBackup = true
    @AppStorage("backupInterval") private var backupInterval = 60
    
    var body: some View {
        Form {
            Section {
                Toggle("Auto-save projects", isOn: $autoSave)
                Toggle("Auto-backup", isOn: $autoBackup)
                
                if autoBackup {
                    Picker("Backup interval", selection: $backupInterval) {
                        Text("Every 30 minutes").tag(30)
                        Text("Every hour").tag(60)
                        Text("Every 2 hours").tag(120)
                    }
                }
            }
        }
        .padding()
    }
}

struct AppearanceSettingsView: View {
    @AppStorage("darkMode") private var darkMode = true
    @AppStorage("accentColor") private var accentColor = "blue"
    
    var body: some View {
        Form {
            Section {
                Toggle("Dark mode", isOn: $darkMode)
                
                Picker("Accent color", selection: $accentColor) {
                    Text("Blue").tag("blue")
                    Text("Purple").tag("purple")
                    Text("Green").tag("green")
                    Text("Orange").tag("orange")
                }
            }
        }
        .padding()
    }
}

struct AdvancedSettingsView: View {
    @AppStorage("showLineNumbers") private var showLineNumbers = true
    @AppStorage("enableLogs") private var enableLogs = false
    
    var body: some View {
        Form {
            Section {
                Toggle("Show line numbers in terminal", isOn: $showLineNumbers)
                Toggle("Enable debug logs", isOn: $enableLogs)
                
                Button("Reset to Defaults") {
                    resetSettings()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
    }
    
    func resetSettings() {
        UserDefaults.standard.removeObject(forKey: "autoSave")
        UserDefaults.standard.removeObject(forKey: "darkMode")
        UserDefaults.standard.removeObject(forKey: "showLineNumbers")
    }
}