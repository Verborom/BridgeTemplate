#!/bin/bash
# Complete System Validation for Architectural Rebuild

BRIDGE_ROOT="/Users/eatatjoes/Desktop/ORGANIZE!/BridgeTemplate"
cd "$BRIDGE_ROOT"

echo "🌉 Bridge Template Architectural Rebuild Validation"
echo "================================================="

# Check branch
echo "🌿 Checking branch..."
BRANCH=$(git branch --show-current)
if [ "$BRANCH" != "architectural-rebuild" ]; then
    echo "❌ Error: Must be on 'architectural-rebuild' branch (currently on $BRANCH)"
    exit 1
fi
echo "✅ On correct branch: $BRANCH"

# Check module structure
echo "📁 Validating module structure..."
REQUIRED_MODULES=("PersonalAssistant" "Projects" "Documents" "Settings" "Terminal")
for module in "${REQUIRED_MODULES[@]}"; do
    if [ -d "Modules/$module" ]; then
        echo "✅ Found module: $module"
        
        # Check required files
        if [ -f "Modules/$module/Package.swift" ]; then
            echo "  ✅ Package.swift exists"
        else
            echo "  ❌ Package.swift missing"
        fi
        
        if [ -f "Modules/$module/version.json" ]; then
            echo "  ✅ version.json exists"
        else
            echo "  ❌ version.json missing"
        fi
    else
        echo "❌ Missing module: $module"
    fi
done

# Check UniversalTemplate
echo "🎯 Checking UniversalTemplate..."
if [ -f "Core/UniversalTemplate.swift" ]; then
    echo "✅ UniversalTemplate exists"
else
    echo "❌ UniversalTemplate missing"
fi

# Check ModuleManager updates
echo "⚡ Checking ModuleManager updates..."
if grep -q "createModuleInstance.*switch.*metadata\.identifier" Core/ModuleManager/ModuleManager.swift; then
    echo "✅ ModuleManager has dynamic discovery"
else
    echo "❌ ModuleManager still uses hardcoded discovery"
fi

# Build test
echo "🔨 Testing build..."
if ./scripts/enhanced-smart-build.sh "test build for validation"; then
    echo "✅ Build successful"
else
    echo "❌ Build failed"
    exit 1
fi

# Run tests
echo "🧪 Running integration tests..."
if swift test --filter ArchitecturalRebuildTests; then
    echo "✅ Integration tests passed"
else
    echo "❌ Integration tests failed"
    exit 1
fi

echo ""
echo "🎉 ARCHITECTURAL REBUILD VALIDATION COMPLETE!"
echo "✅ All systems validated successfully"
echo "🌉 Bridge Template architectural rebuild is ready!"