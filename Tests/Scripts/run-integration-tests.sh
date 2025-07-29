#!/bin/bash
# Automated Integration Test Runner for Architectural Rebuild

set -e

BRIDGE_ROOT="/Users/eatatjoes/Desktop/ORGANIZE!/BridgeTemplate"
cd "$BRIDGE_ROOT"

echo "🧪 Starting Architectural Rebuild Integration Tests..."
echo "📍 Working from: $(pwd)"
echo "🌿 Branch: $(git branch --show-current)"

# Ensure we're on the correct branch
if [ "$(git branch --show-current)" != "architectural-rebuild" ]; then
    echo "❌ Error: Must be on 'architectural-rebuild' branch"
    exit 1
fi

# Build all modules first
echo "🔨 Building all modules..."
./scripts/enhanced-smart-build.sh "build all modules for integration testing"

# Run Swift tests
echo "🧪 Running Swift integration tests..."
swift test --package-path . --filter ArchitecturalRebuildTests

# Test module discovery
echo "🔍 Testing module discovery..."
swift run TestModuleDiscovery

# Test dynamic loading
echo "⚡ Testing dynamic module loading..."
for module in PersonalAssistant Projects Documents Settings Terminal; do
    echo "  Testing $module..."
    swift run TestModuleLoading "$module"
done

# Test UniversalTemplate
echo "🎯 Testing UniversalTemplate system..."
swift run TestUniversalTemplate

# Test hot-swapping
echo "🔄 Testing hot-swap functionality..."
swift run TestHotSwap

# Performance testing
echo "⏱️ Running performance tests..."
swift run PerformanceTest

# Integration test
echo "🌉 Running full integration test..."
swift run FullIntegrationTest

echo "✅ All integration tests completed successfully!"
echo "🎉 Architectural rebuild validation complete!"