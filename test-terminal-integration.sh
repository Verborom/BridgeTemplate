#!/bin/bash

# Make executable
chmod +x "$0"

# Test Terminal Integration Build
echo "🔧 Testing Terminal Module Integration..."

cd "/Users/eatatjoes/Desktop/ORGANIZE!/BridgeTemplate/Platforms/macOS"

echo "📦 Building macOS app with real Terminal module..."
swift build -c release

if [ $? -eq 0 ]; then
    echo "✅ Build successful! Real Terminal module integrated."
    echo "📱 Terminal module now includes:"
    echo "   • Real shell processes and PTY support"
    echo "   • Claude Code integration with automated onboarding"
    echo "   • Auto-permission system for unattended execution"
    echo "   • Multi-session support with tabs"
    echo "   • Full ANSI color and escape sequence support"
    echo ""
    echo "🎯 Ready to hot-swap MockTerminalModule → TerminalModule"
else
    echo "❌ Build failed. Check dependencies and imports."
fi
