#!/bin/bash

# Build script for NewBridgeMac application
# Builds to safe isolated location

set -e

BRIDGE_ROOT="/Users/eatatjoes/Desktop/ORGANIZE!/BridgeTemplate"
BUILD_DIR="$BRIDGE_ROOT/builds/architectural-rebuild"
APP_NAME="NewBridgeMac.app"

echo "🌉 Building NewBridgeMac with Architectural Rebuild System"
echo "================================================================"

# Ensure we're on the correct branch
cd "$BRIDGE_ROOT"
BRANCH=$(git branch --show-current)
if [ "$BRANCH" != "architectural-rebuild" ]; then
    echo "❌ Error: Must be on 'architectural-rebuild' branch (currently on $BRANCH)"
    exit 1
fi

echo "✅ On correct branch: $BRANCH"

# Create build directory
echo "📁 Creating build directory..."
mkdir -p "$BUILD_DIR"

# Build the new app
echo "🔨 Building NewBridgeMac..."
cd "$BRIDGE_ROOT/Platforms/macOS/NewBridgeMac"

# Clean previous build
swift package clean

# Build release version
swift build -c release

# Create app bundle
echo "📦 Creating app bundle..."
BUILD_PATH=$(swift build -c release --show-bin-path)
EXECUTABLE_PATH="$BUILD_PATH/NewBridgeMac"

# Create .app structure
APP_PATH="$BUILD_DIR/$APP_NAME"
rm -rf "$APP_PATH"
mkdir -p "$APP_PATH/Contents/MacOS"
mkdir -p "$APP_PATH/Contents/Resources"

# Copy executable
cp "$EXECUTABLE_PATH" "$APP_PATH/Contents/MacOS/"

# Create Info.plist
cat > "$APP_PATH/Contents/Info.plist" << EOF
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
    <key>CFBundleVersion</key>
    <string>3.0.0</string>
    <key>CFBundleShortVersionString</key>
    <string>3.0.0</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
</dict>
</plist>
EOF

# Set executable permissions
chmod +x "$APP_PATH/Contents/MacOS/NewBridgeMac"

echo "✅ NewBridgeMac.app built successfully!"
echo "📍 Location: $APP_PATH"
echo "🚀 You can now double-click the app to test the architectural rebuild system"
echo ""
echo "🌉 Architectural Rebuild App Ready for Testing!"