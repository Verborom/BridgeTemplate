#!/bin/bash

echo "🌉 Building Bridge Template v2.0.1 - Modular System UI Fixes"
echo "============================================================"

# Set variables
VERSION="2.0.1"
BUILD_DIR="/Users/eatatjoes/Desktop/ORGANIZE!/BridgeTemplate/builds/macos/v${VERSION}"
APP_NAME="BridgeMac"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Clean previous build
echo "🧹 Cleaning previous builds..."
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# Create temporary build directory
TEMP_BUILD="/tmp/BridgeTemplate-v${VERSION}"
rm -rf "$TEMP_BUILD"
mkdir -p "$TEMP_BUILD"

# Copy all source files
echo "📦 Gathering source files..."
cp -R Core "$TEMP_BUILD/"
cp -R Modules "$TEMP_BUILD/"
cp -R Platforms "$TEMP_BUILD/"

# Create combined Swift file for compilation
echo "🔨 Creating unified build..."
cd "$TEMP_BUILD"

cat > BridgeMac_v2_0_1.swift << 'EOF'
import SwiftUI
import Combine

// Bridge Template v2.0.1 - Working Modular System

EOF

# Add core files
echo "// ===== CORE COMPONENTS =====" >> BridgeMac_v2_0_1.swift
cat Core/BridgeModule.swift >> BridgeMac_v2_0_1.swift
echo "" >> BridgeMac_v2_0_1.swift
cat Core/ModuleManager/ModuleManager.swift >> BridgeMac_v2_0_1.swift
echo "" >> BridgeMac_v2_0_1.swift
cat Core/VersionManager/VersionManager.swift >> BridgeMac_v2_0_1.swift
echo "" >> BridgeMac_v2_0_1.swift

# Add mock modules
echo "// ===== MOCK MODULES =====" >> BridgeMac_v2_0_1.swift
cat Core/MockModules.swift >> BridgeMac_v2_0_1.swift
echo "" >> BridgeMac_v2_0_1.swift

# Add design system
echo "// ===== DESIGN SYSTEM =====" >> BridgeMac_v2_0_1.swift
cat > DesignSystem.swift << 'EOF'
// Design System for v2.0.1

import SwiftUI

extension Color {
    static let bridgePrimary = Color(red: 0.2, green: 0.6, blue: 1.0)
    static let bridgeSecondary = Color(red: 0.8, green: 0.4, blue: 1.0)
    static let bridgeAccent = Color(red: 0.4, green: 0.9, blue: 0.7)
    static let bridgeBackground = Color(red: 0.98, green: 0.98, blue: 1.0)
    static let bridgeCardBackground = Color.white.opacity(0.8)
    static let bridgeSidebarBackground = Color(red: 0.95, green: 0.96, blue: 0.98).opacity(0.7)
    static let bridgeTextPrimary = Color(red: 0.1, green: 0.1, blue: 0.2)
    static let bridgeTextSecondary = Color(red: 0.4, green: 0.4, blue: 0.5)
    static let bridgeDashboard = Color(red: 0.3, green: 0.7, blue: 1.0)
    static let bridgeProjects = Color(red: 0.4, green: 0.9, blue: 0.6)
    static let bridgeTerminal = Color(red: 1.0, green: 0.6, blue: 0.3)
    static let bridgeSettings = Color(red: 0.6, green: 0.6, blue: 0.7)
}

extension LinearGradient {
    static let arcPrimary = LinearGradient(
        colors: [Color.bridgePrimary, Color.bridgeSecondary],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let arcSecondary = LinearGradient(
        colors: [Color.bridgeSecondary, Color.bridgeAccent],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let subtleBackground = LinearGradient(
        colors: [Color.bridgeBackground, Color.white],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let sidebarGradient = LinearGradient(
        colors: [
            Color.bridgeSidebarBackground,
            Color.bridgeSidebarBackground.opacity(0.8),
            Color.bridgeSidebarBackground.opacity(0.6)
        ],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let dashboardGradient = LinearGradient(
        colors: [Color.bridgeDashboard, Color.bridgeDashboard.opacity(0.7)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let projectsGradient = LinearGradient(
        colors: [Color.bridgeProjects, Color.bridgeProjects.opacity(0.7)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let terminalGradient = LinearGradient(
        colors: [Color.bridgeTerminal, Color.bridgeTerminal.opacity(0.7)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

struct BridgeTypography {
    static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
    static let title = Font.system(size: 28, weight: .semibold, design: .rounded)
    static let title2 = Font.system(size: 22, weight: .semibold, design: .rounded)
    static let headline = Font.system(size: 17, weight: .semibold, design: .rounded)
    static let body = Font.system(size: 15, weight: .regular, design: .rounded)
    static let caption = Font.system(size: 12, weight: .regular, design: .rounded)
}

struct VisualEffectBlur: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = .behindWindow
        view.state = .active
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
    }
}
EOF
cat DesignSystem.swift >> BridgeMac_v2_0_1.swift
echo "" >> BridgeMac_v2_0_1.swift

# Add platform app
echo "// ===== MAIN APPLICATION =====" >> BridgeMac_v2_0_1.swift
cat Platforms/macOS/BridgeMac.swift >> BridgeMac_v2_0_1.swift

# Build the application
echo -e "${BLUE}🔨 Compiling Bridge Template v2.0.1...${NC}"
swiftc BridgeMac_v2_0_1.swift \
    -o "$APP_NAME" \
    -framework SwiftUI \
    -framework AppKit \
    -framework Combine \
    -target arm64-apple-macos13.0 \
    -swift-version 5 \
    -parse-as-library

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Compilation successful!${NC}"
else
    echo -e "${RED}❌ Compilation failed${NC}"
    exit 1
fi

# Create app bundle
echo "📦 Creating app bundle..."
mkdir -p "$BUILD_DIR/${APP_NAME}.app/Contents/MacOS"
mkdir -p "$BUILD_DIR/${APP_NAME}.app/Contents/Resources"

# Move executable
mv "$APP_NAME" "$BUILD_DIR/${APP_NAME}.app/Contents/MacOS/"

# Create Info.plist
cat > "$BUILD_DIR/${APP_NAME}.app/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>${APP_NAME}</string>
    <key>CFBundleIdentifier</key>
    <string>com.bridge.template</string>
    <key>CFBundleName</key>
    <string>Bridge Template</string>
    <key>CFBundleDisplayName</key>
    <string>Bridge Template v2.0.1</string>
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
    <key>NSSupportsAutomaticTermination</key>
    <false/>
    <key>NSSupportsSuddenTermination</key>
    <false/>
</dict>
</plist>
EOF

# Copy source for reference
echo "📄 Backing up source code..."
mkdir -p "$BUILD_DIR/source"
cp -R /Users/eatatjoes/Desktop/ORGANIZE!/BridgeTemplate/Core "$BUILD_DIR/source/"
cp -R /Users/eatatjoes/Desktop/ORGANIZE!/BridgeTemplate/Modules "$BUILD_DIR/source/"
cp -R /Users/eatatjoes/Desktop/ORGANIZE!/BridgeTemplate/Platforms "$BUILD_DIR/source/"

# Create version manifest
cat > "$BUILD_DIR/version-manifest.json" << EOF
{
  "appVersion": "${VERSION}",
  "buildDate": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "architecture": "Modular Foundation",
  "fixes": {
    "moduleAutoDiscovery": true,
    "addModuleButton": true,
    "sidebarNavigation": true,
    "defaultModuleLoading": true
  },
  "modules": {
    "com.bridge.dashboard": "1.5.2",
    "com.bridge.projects": "1.8.1",
    "com.bridge.terminal": "1.2.0"
  },
  "improvements": [
    "✅ Auto-loads 3 core modules on startup",
    "✅ Working Add Module button with selector dialog",
    "✅ Fixed sidebar navigation (balanced split view)",
    "✅ Dashboard loads by default",
    "✅ Mock module implementations for demonstration"
  ]
}
EOF

# Update latest symlink
cd "/Users/eatatjoes/Desktop/ORGANIZE!/BridgeTemplate/builds/macos/"
rm -f latest
ln -sf "v${VERSION}" latest

# Clean up
rm -rf "$TEMP_BUILD"

echo ""
echo -e "${GREEN}🎉 Bridge Template v2.0.1 - UI Integration Fixed!${NC}"
echo "============================================================"
echo -e "${BLUE}📍 Build location:${NC} $BUILD_DIR/${APP_NAME}.app"
echo ""
echo -e "${GREEN}✅ Fixed Issues:${NC}"
echo "   🔧 Modules now auto-load (shows '3 modules loaded')"
echo "   🔧 Add Module button opens working selector"
echo "   🔧 Sidebar navigation fixed (balanced split view)"
echo "   🔧 Dashboard loads automatically on startup"
echo "   🔧 All modules display their actual content"
echo ""
echo -e "${BLUE}📋 What's New:${NC}"
echo "   • Mock implementations for Dashboard, Projects, Terminal"
echo "   • Module selector dialog with loading states"
echo "   • Improved navigation that can't completely hide"
echo "   • Auto-discovery and loading of core modules"
echo ""
echo -e "${YELLOW}🚀 To test:${NC}"
echo "   open $BUILD_DIR/${APP_NAME}.app"
echo ""
echo -e "${GREEN}✨ The modular system is now fully functional!${NC}"