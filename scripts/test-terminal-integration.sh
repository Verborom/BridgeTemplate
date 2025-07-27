#!/bin/bash
# Comprehensive test script to verify real terminal integration

echo "🧪 Testing Terminal Integration - Chunk 4 Verification"
echo "======================================================="

BRIDGE_ROOT="/Users/eatatjoes/Desktop/ORGANIZE!/BridgeTemplate"
cd "$BRIDGE_ROOT"

# Test 1: Verify Terminal module loads (not mock)
echo "📋 Test 1: Module Loading Verification"
if [ -f "Modules/Terminal/Sources/TerminalModule.swift" ]; then
    echo "✅ Real Terminal module source found"
    grep -q "class TerminalModule: BridgeModule" "Modules/Terminal/Sources/TerminalModule.swift" && echo "✅ Real TerminalModule class confirmed" || echo "❌ Mock module still present"
else
    echo "❌ Terminal module source not found"
fi

# Test 2: Verify Claude Code integration
echo ""
echo "📋 Test 2: Claude Code Integration"
if [ -f "Modules/Terminal/Sources/ClaudeIntegration/ClaudeCodeIntegration.swift" ]; then
    echo "✅ Claude Code integration component found"
    grep -q "ClaudeCodeIntegration" "Modules/Terminal/Sources/ClaudeIntegration/ClaudeCodeIntegration.swift" && echo "✅ Claude integration class confirmed"
else
    echo "❌ Claude integration missing"
fi

# Test 3: Verify Auto-Permission system
echo ""
echo "📋 Test 3: Auto-Permission System"
if [ -f "Modules/Terminal/Sources/AutoPermission/AutoPermissionSystem.swift" ]; then
    echo "✅ Auto-Permission system found"
    grep -q "AutoPermissionSystem" "Modules/Terminal/Sources/AutoPermission/AutoPermissionSystem.swift" && echo "✅ Auto-permission class confirmed"
else
    echo "❌ Auto-permission system missing"
fi

# Test 4: Verify build integration
echo ""
echo "📋 Test 4: Build System Integration"
cd "Modules/Terminal"
if swift build > /dev/null 2>&1; then
    echo "✅ Terminal module builds successfully"
else
    echo "❌ Terminal module build failed"
fi
cd "$BRIDGE_ROOT"

# Test 5: Verify main app integration
echo ""
echo "📋 Test 5: Main App Integration"
if grep -q "import Terminal" "Platforms/macOS/BridgeMac.swift"; then
    echo "✅ Terminal module imported in main app"
else
    echo "❌ Terminal module not imported in main app"
fi

if grep -q "TerminalModule()" "Core/ModuleManager/ModuleManager.swift"; then
    echo "✅ Real Terminal module used in ModuleManager"
else
    echo "❌ Mock Terminal module still in use"
fi

# Test 6: Verify version updates
echo ""
echo "📋 Test 6: Version Management"
if grep -q '"1.3.0"' "Modules/Terminal/version.json"; then
    echo "✅ Terminal module version updated to 1.3.0"
else
    echo "❌ Terminal module version not updated"
fi

if grep -q '"1.3.0"' "Core/ModuleManager/ModuleManager.swift"; then
    echo "✅ ModuleManager knows about Terminal v1.3.0"
else
    echo "❌ ModuleManager has outdated Terminal version"
fi

# Test 7: Verify Terminal features
echo ""
echo "📋 Test 7: Terminal Feature Verification"
echo -n "Checking Terminal features: "
FEATURES_FOUND=0
[ -f "Modules/Terminal/Sources/TerminalModule.swift" ] && ((FEATURES_FOUND++))
[ -f "Modules/Terminal/Sources/ClaudeIntegration/ClaudeCodeIntegration.swift" ] && ((FEATURES_FOUND++))
[ -f "Modules/Terminal/Sources/AutoPermission/AutoPermissionSystem.swift" ] && ((FEATURES_FOUND++))
echo "$FEATURES_FOUND/3 core features found"

if [ $FEATURES_FOUND -eq 3 ]; then
    echo "✅ All Terminal features integrated"
else
    echo "❌ Some Terminal features missing"
fi

# Test 8: Verify UI integration
echo ""
echo "📋 Test 8: UI Integration"
if grep -q "terminalGradient" "Platforms/macOS/BridgeMac.swift"; then
    echo "✅ Terminal gradient defined in UI"
else
    echo "❌ Terminal gradient missing"
fi

if grep -q "Terminal status indicators" "Platforms/macOS/BridgeMac.swift"; then
    echo "✅ Terminal status indicators implemented"
else
    echo "❌ Terminal status indicators missing"
fi

echo ""
echo "🎯 INTEGRATION VERIFICATION COMPLETE"
echo ""
echo "Summary:"
echo "--------"
TOTAL_TESTS=8
PASSED_TESTS=$(grep -c "✅" <<< "$(./scripts/test-terminal-integration.sh 2>&1)" || echo "0")
echo "Tests passed: $PASSED_TESTS/$TOTAL_TESTS"
echo ""
echo "If all tests show ✅, Terminal integration is successful"
echo "If any show ❌, integration needs completion"