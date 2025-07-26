#!/bin/bash

echo "🌉 Building BridgeMac - macOS Foundation App"
echo "=========================================="

# Set variables
APP_NAME="BridgeMac"
BUILD_DIR="$(pwd)"
VERSION="1.0.0"

# Clean previous build
echo "🧹 Cleaning previous build..."
rm -rf "${APP_NAME}.app"
rm -rf build/

# Create app structure
echo "📁 Creating app structure..."
mkdir -p "${APP_NAME}.app/Contents/MacOS"
mkdir -p "${APP_NAME}.app/Contents/Resources"

# Combine all Swift files
echo "📦 Combining Swift files..."
cat > BridgeMac_Combined.swift << 'EOF'
import SwiftUI

// MARK: - Main App
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

EOF

# Add the view files
cat BridgeMac/Views/*.swift >> BridgeMac_Combined.swift 2>/dev/null || true

# Compile the application
echo "🔨 Compiling macOS application..."
swiftc BridgeMac_Combined.swift \
    -o "${APP_NAME}.app/Contents/MacOS/${APP_NAME}" \
    -framework SwiftUI \
    -framework AppKit \
    -target arm64-apple-macos13.0 \
    -swift-version 5 \
    -parse-as-library

if [ $? -eq 0 ]; then
    echo "✅ Compilation successful!"
else
    echo "❌ Compilation failed!"
    # Keep the combined file for debugging
    echo "Debug file: BridgeMac_Combined.swift"
    exit 1
fi

# Create Info.plist
echo "📝 Creating Info.plist..."
cat > "${APP_NAME}.app/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>${APP_NAME}</string>
    <key>CFBundleIdentifier</key>
    <string>com.bridge.mac</string>
    <key>CFBundleName</key>
    <string>BridgeMac</string>
    <key>CFBundleDisplayName</key>
    <string>Bridge for macOS</string>
    <key>CFBundleVersion</key>
    <string>${VERSION}</string>
    <key>CFBundleShortVersionString</key>
    <string>${VERSION}</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>LSApplicationCategoryType</key>
    <string>public.app-category.developer-tools</string>
</dict>
</plist>
EOF

# Clean up
rm -f BridgeMac_Combined.swift

# Make executable
chmod +x "${APP_NAME}.app/Contents/MacOS/${APP_NAME}"

# Move to builds directory
echo "📦 Moving to builds directory..."
mkdir -p ../../builds/macos/v${VERSION}
cp -R "${APP_NAME}.app" "../../builds/macos/v${VERSION}/"

# Update latest symlink
cd ../../builds/macos/
rm -f latest
ln -sf "v${VERSION}" latest
cd "$BUILD_DIR"

echo ""
echo "🎉 Build complete!"
echo "=========================================="
echo "📍 App location: $(pwd)/${APP_NAME}.app"
echo "📍 Build location: ../../builds/macos/v${VERSION}/${APP_NAME}.app"
echo ""
echo "✨ Features:"
echo "   - Modular architecture"
echo "   - Dashboard view"
echo "   - Projects management"
echo "   - Integrated terminal"
echo "   - Settings/preferences"
echo ""
echo "💡 To run: open ${APP_NAME}.app"
echo "💡 Or: open ../../builds/macos/latest/${APP_NAME}.app"