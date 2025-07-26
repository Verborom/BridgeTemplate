#!/bin/bash

echo "Building SimpleBridge app..."

# Create app bundle
rm -rf SimpleBridge.app
mkdir -p SimpleBridge.app/Contents/MacOS
mkdir -p SimpleBridge.app/Contents/Resources

# Compile
swiftc SimpleBridge.swift -o SimpleBridge.app/Contents/MacOS/SimpleBridge -framework SwiftUI -parse-as-library

# Create Info.plist
cat > SimpleBridge.app/Contents/Info.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>SimpleBridge</string>
    <key>CFBundleIdentifier</key>
    <string>com.bridge.simple</string>
    <key>CFBundleName</key>
    <string>SimpleBridge</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
</dict>
</plist>
EOF

echo "Build complete! Run: open SimpleBridge.app"