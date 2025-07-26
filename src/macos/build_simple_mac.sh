#!/bin/bash

echo "🌉 Building BridgeMac Simple Foundation"

# Clean and create app
rm -rf BridgeMac.app
mkdir -p BridgeMac.app/Contents/MacOS

# Compile
swiftc BridgeMacSimple.swift \
    -o BridgeMac.app/Contents/MacOS/BridgeMac \
    -framework SwiftUI \
    -parse-as-library

# Create Info.plist
cat > BridgeMac.app/Contents/Info.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>BridgeMac</string>
    <key>CFBundleIdentifier</key>
    <string>com.bridge.mac</string>
    <key>CFBundleName</key>
    <string>BridgeMac</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOF

echo "✅ Build complete! Run: open BridgeMac.app"