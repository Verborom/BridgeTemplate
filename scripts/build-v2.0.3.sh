#!/bin/bash

# Build script for v2.0.3 - Real Terminal Module Integration (Fixed)

set -e

echo "🔨 Building Bridge Template v2.0.3 with REAL Terminal v1.3.0 (Fixed)..."

# Get project root
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

# Version info
VERSION="2.0.3"
BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Create build directory
BUILD_DIR="$PROJECT_ROOT/builds/macos/v$VERSION"
mkdir -p "$BUILD_DIR"

# Build the macOS app
echo "📦 Building macOS app..."
cd "$PROJECT_ROOT/Platforms/macOS"
swift build -c release --product BridgeMac

# Find the built executable
BUILT_EXEC="$(swift build -c release --show-bin-path)/BridgeMac"

# Create app bundle
APP_DIR="$BUILD_DIR/BridgeMac.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

# Copy executable
cp "$BUILT_EXEC" "$MACOS_DIR/BridgeMac"

# Create Info.plist
cat > "$CONTENTS_DIR/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>BridgeMac</string>
    <key>CFBundleIdentifier</key>
    <string>com.bridge.template.macos</string>
    <key>CFBundleName</key>
    <string>Bridge Template</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>$VERSION</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOF

# Create version manifest
cat > "$BUILD_DIR/version-manifest.json" <<EOF
{
  "appVersion": "$VERSION",
  "buildDate": "$BUILD_DATE",
  "architecture": "Modular Foundation",
  "features": {
    "realTerminalModule": true,
    "claudeCodeIntegration": true,
    "autoPermissionSystem": true,
    "multiSessionSupport": true,
    "hotSwappable": true,
    "typealiasIntegration": true
  },
  "modules": {
    "com.bridge.dashboard": "1.5.2",
    "com.bridge.projects": "1.8.1",
    "com.bridge.terminal": "1.3.0"
  },
  "improvements": [
    "✅ REAL Terminal module v1.3.0 with full functionality",
    "✅ Fixed MockTerminalModule to use RealTerminalModule via typealias",
    "✅ Native macOS terminal with PTY support",
    "✅ Claude Code integration with automated onboarding",
    "✅ Auto-permission system with keychain security",
    "✅ Multi-session support with tabs",
    "✅ Full ANSI color and escape sequence support",
    "✅ Hot-swappable architecture maintained"
  ],
  "fixes": [
    "Fixed module loading to use real Terminal implementation",
    "Resolved type mismatch between Core and Terminal BridgeModule protocols",
    "Made Terminal module classes have public initializers"
  ]
}
EOF

# Update symlink
cd "$PROJECT_ROOT/builds/macos"
rm -f latest
ln -s "v$VERSION" latest

echo "✅ Build complete!"
echo "📍 Location: $BUILD_DIR/BridgeMac.app"
echo "🚀 Run with: open '$BUILD_DIR/BridgeMac.app'"

echo ""
echo "🎉 Bridge Template v$VERSION built successfully with REAL Terminal module!"