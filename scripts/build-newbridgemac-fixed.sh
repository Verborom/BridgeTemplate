#!/bin/bash

# Build NewBridgeMac with fixed module discovery
# This script builds the app with real modules

set -e

echo "🚀 Building NewBridgeMac with Real Modules"
echo "=========================================="
echo ""

cd /Users/eatatjoes/Desktop/ORGANIZE!/BridgeTemplate/Platforms/macOS/NewBridgeMac

# Clean previous builds
echo "🧹 Cleaning previous builds..."
rm -rf .build

# Build with simplified approach
echo "📦 Building NewBridgeMac..."
swift build --configuration release --arch arm64 2>&1 | grep -v warning || true

# Create app bundle
echo "🏗️ Creating app bundle..."
APP_DIR="/Users/eatatjoes/Desktop/ORGANIZE!/BridgeTemplate/builds/architectural-rebuild/NewBridgeMac-Fixed.app"
rm -rf "$APP_DIR"
mkdir -p "$APP_DIR/Contents/MacOS"
mkdir -p "$APP_DIR/Contents/Resources"

# Copy executable
if [ -f ".build/arm64-apple-macosx/release/NewBridgeMac" ]; then
    cp .build/arm64-apple-macosx/release/NewBridgeMac "$APP_DIR/Contents/MacOS/"
elif [ -f ".build/release/NewBridgeMac" ]; then
    cp .build/release/NewBridgeMac "$APP_DIR/Contents/MacOS/"
else
    echo "❌ Could not find built executable"
    exit 1
fi

# Create Info.plist
cat > "$APP_DIR/Contents/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>NewBridgeMac</string>
    <key>CFBundleIdentifier</key>
    <string>com.bridge.newbridgemac</string>
    <key>CFBundleName</key>
    <string>NewBridgeMac</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
</dict>
</plist>
EOF

# Make executable
chmod +x "$APP_DIR/Contents/MacOS/NewBridgeMac"

echo ""
echo "✅ Build complete!"
echo "📍 App location: $APP_DIR"
echo ""
echo "🧪 Module Discovery Fix Applied:"
echo "   - SimplifiedModuleDiscovery imports real modules"
echo "   - Returns TerminalModule(), ProjectsModule(), etc."
echo "   - No more GenericBridgeModule placeholders"
echo ""
echo "🚀 Opening app..."
open "$APP_DIR"