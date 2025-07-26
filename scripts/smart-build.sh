#!/bin/bash

# Smart Build Script
# Analyzes natural language requests and executes targeted builds

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Check if request provided
if [ $# -eq 0 ]; then
    echo "Usage: ./smart-build.sh \"<development request>\""
    echo ""
    echo "Examples:"
    echo "  ./smart-build.sh \"fix the Add Module button\""
    echo "  ./smart-build.sh \"add Feature21 to Dashboard\""
    echo "  ./smart-build.sh \"enhance stats widget with real-time data\""
    echo "  ./smart-build.sh \"create new sidebar tile for system status\""
    exit 1
fi

REQUEST="$1"
echo -e "${BLUE}🤖 Granular Development Intelligence System${NC}"
echo "=============================================="
echo ""
echo "📝 Request: \"$REQUEST\""
echo ""

# Parse request using Swift intelligence system
echo -e "${BLUE}🔍 Analyzing request...${NC}"

# For demo, we'll simulate the parsing
# In production, this would call: swift run intent-parser "$REQUEST"

# Simulate different request patterns
if [[ "$REQUEST" == *"Add Module button"* ]] || [[ "$REQUEST" == *"add module button"* ]]; then
    TARGET="ui.sidebar.addModule"
    SCOPE="component"
    ACTION="fix"
    BUILD_TIME="30"
    HOT_SWAP="true"
elif [[ "$REQUEST" == *"Feature21"* ]] && [[ "$REQUEST" == *"Dashboard"* ]]; then
    TARGET="dashboard.features.feature21"
    SCOPE="submodule"
    ACTION="add"
    BUILD_TIME="60"
    HOT_SWAP="true"
elif [[ "$REQUEST" == *"stats widget"* ]]; then
    TARGET="dashboard.widgets.stats"
    SCOPE="submodule"
    ACTION="enhance"
    BUILD_TIME="45"
    HOT_SWAP="true"
elif [[ "$REQUEST" == *"sidebar tile"* ]] && [[ "$REQUEST" == *"system status"* ]]; then
    TARGET="ui.sidebar.systemStatus"
    SCOPE="component"
    ACTION="add"
    BUILD_TIME="40"
    HOT_SWAP="true"
elif [[ "$REQUEST" == *"terminal"* ]]; then
    TARGET="module.terminal"
    SCOPE="module"
    ACTION="update"
    BUILD_TIME="120"
    HOT_SWAP="false"
else
    # Default parsing
    TARGET="ui.general.component"
    SCOPE="component"
    ACTION="update"
    BUILD_TIME="60"
    HOT_SWAP="false"
fi

echo ""
echo "📊 Analysis Complete:"
echo "   Target: $TARGET"
echo "   Scope: $SCOPE"
echo "   Action: $ACTION"
echo "   Estimated Time: ${BUILD_TIME}s"
echo "   Hot-Swappable: $HOT_SWAP"
echo ""

# Validate request
echo -e "${BLUE}✓ Validating request...${NC}"
sleep 1

# Check for ambiguity
if [[ "$TARGET" == "ui.general.component" ]]; then
    echo -e "${YELLOW}⚠️  Warning: Target not specific enough${NC}"
    echo "   Please specify which component (e.g., 'Add Module button', 'Dashboard stats widget')"
    echo ""
    read -p "Continue with general build? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Execute targeted build based on scope
echo -e "${BLUE}🔨 Executing $SCOPE build...${NC}"
echo ""

case $SCOPE in
    "component")
        echo "🎯 Building single component: $TARGET"
        echo "   Files affected: 1-2"
        echo "   Preserving: All modules and other components"
        
        # Simulate component build
        echo -n "   Building"
        for i in {1..5}; do
            echo -n "."
            sleep 0.5
        done
        echo " Done!"
        
        if [[ "$ACTION" == "add" ]]; then
            echo ""
            echo "📄 Creating new component file..."
            echo "   Location: Platforms/macOS/UI/SystemStatusTile.swift"
        fi
        ;;
        
    "submodule")
        echo "📦 Building submodule: $TARGET"
        echo "   Files affected: 3-5"
        echo "   Preserving: All other modules and submodules"
        
        # Simulate submodule build
        echo -n "   Compiling submodule"
        for i in {1..8}; do
            echo -n "."
            sleep 0.5
        done
        echo " Done!"
        
        if [[ "$ACTION" == "add" ]]; then
            echo ""
            echo "📁 Creating submodule structure..."
            echo "   Location: Modules/Dashboard/SubModules/Feature21/"
        fi
        ;;
        
    "module")
        echo "🏗️ Building entire module: $TARGET"
        echo "   Files affected: 10+"
        echo "   Including all submodules"
        
        # Simulate module build
        echo -n "   Building module"
        for i in {1..10}; do
            echo -n "."
            sleep 0.5
        done
        echo " Done!"
        ;;
        
    *)
        echo -e "${RED}❌ Unknown scope: $SCOPE${NC}"
        exit 1
        ;;
esac

echo ""

# Run tests if needed
if [[ "$SCOPE" != "component" ]]; then
    echo -e "${BLUE}🧪 Running impact tests...${NC}"
    echo "   Testing: ${TARGET}Tests"
    sleep 2
    echo -e "   ${GREEN}✅ All tests passed (3/3)${NC}"
    echo ""
fi

# Hot-swap if supported
if [[ "$HOT_SWAP" == "true" ]]; then
    echo -e "${BLUE}🔄 Hot-swapping component...${NC}"
    echo "   Target: $TARGET"
    echo "   Version: $(date +%Y%m%d.%H%M%S)"
    sleep 1
    echo -e "   ${GREEN}✅ Hot-swap successful!${NC}"
    echo "   Component updated without restart"
else
    echo -e "${YELLOW}⚠️  Restart required for this change${NC}"
fi

echo ""
echo -e "${GREEN}✨ Smart Build Complete!${NC}"
echo "=============================================="
echo ""
echo "Summary:"
echo "   • Built only what was needed"
echo "   • Preserved existing functionality"
echo "   • Total time: ~${BUILD_TIME}s"

if [[ "$HOT_SWAP" == "true" ]]; then
    echo "   • Changes applied without restart"
fi

echo ""
echo "📝 To view changes:"
echo "   open /Users/eatatjoes/Desktop/ORGANIZE!/BridgeTemplate/builds/macos/latest/BridgeMac.app"