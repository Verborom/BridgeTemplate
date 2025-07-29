#!/bin/bash

# Create remaining modules using UniversalTemplate
# This script creates Projects, Documents, and Settings modules

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Base paths
BRIDGE_ROOT="/Users/eatatjoes/Desktop/ORGANIZE!/BridgeTemplate"
MODULES_PATH="$BRIDGE_ROOT/Modules"
UNIVERSAL_TEMPLATE="$BRIDGE_ROOT/UniversalTemplate"
CUSTOMIZE_SCRIPT="$BRIDGE_ROOT/scripts/CustomizeSubmodule.sh"

echo -e "${BLUE}🚀 Creating Remaining Modules${NC}"
echo "=================================="

# Function to create a module
create_module() {
    local MODULE_NAME=$1
    local MODULE_ID=$2
    local MODULE_PATH="$MODULES_PATH/$MODULE_NAME"
    
    echo -e "\n${GREEN}📦 Creating $MODULE_NAME module...${NC}"
    
    # Copy UniversalTemplate
    if [ ! -d "$MODULE_PATH" ]; then
        cp -r "$UNIVERSAL_TEMPLATE" "$MODULE_PATH"
        echo "  ✅ Copied UniversalTemplate"
    else
        echo "  ⚠️  $MODULE_NAME already exists, skipping copy"
        return
    fi
    
    # Customize the module
    "$CUSTOMIZE_SCRIPT" "$MODULE_PATH" "$MODULE_NAME" "$MODULE_ID"
    
    # Remove UniversalCLI if it exists (not needed for modules)
    rm -rf "$MODULE_PATH/Sources/UniversalCLI"
    
    # Update Package.swift to remove CLI
    sed -i '' '/"universal-cli"/d' "$MODULE_PATH/Package.swift"
    sed -i '' '/UniversalCLI/d' "$MODULE_PATH/Package.swift"
    
    echo "  ✅ $MODULE_NAME module created"
}

# Function to create submodules for a module
create_submodules() {
    local MODULE_NAME=$1
    local MODULE_PATH="$MODULES_PATH/$MODULE_NAME"
    shift
    local SUBMODULES=("$@")
    
    echo -e "\n${BLUE}📁 Creating submodules for $MODULE_NAME...${NC}"
    
    # Create SubModules directory
    mkdir -p "$MODULE_PATH/SubModules"
    
    for SUBMODULE in "${SUBMODULES[@]}"; do
        local SUBMODULE_DIR=$(echo "$SUBMODULE" | tr ' ' '')
        local SUBMODULE_PATH="$MODULE_PATH/SubModules/$SUBMODULE_DIR"
        local SUBMODULE_ID="com.bridge.$(echo $MODULE_NAME | tr '[:upper:]' '[:lower:]').$(echo $SUBMODULE_DIR | tr '[:upper:]' '[:lower:]')"
        
        echo "  Creating $SUBMODULE submodule..."
        
        # Copy UniversalTemplate
        if [ ! -d "$SUBMODULE_PATH" ]; then
            cp -r "$UNIVERSAL_TEMPLATE" "$SUBMODULE_PATH"
        fi
        
        # Customize submodule
        "$CUSTOMIZE_SCRIPT" "$SUBMODULE_PATH" "$SUBMODULE_DIR" "$SUBMODULE_ID"
        
        # Remove UniversalCLI
        rm -rf "$SUBMODULE_PATH/Sources/UniversalCLI"
        
        # Update Package.swift
        sed -i '' '/"universal-cli"/d' "$SUBMODULE_PATH/Package.swift"
        sed -i '' '/UniversalCLI/d' "$SUBMODULE_PATH/Package.swift"
        
        echo "    ✅ $SUBMODULE created"
    done
    
    # Update main module Package.swift to include submodules
    local DEPS=""
    for SUBMODULE in "${SUBMODULES[@]}"; do
        local SUBMODULE_DIR=$(echo "$SUBMODULE" | tr ' ' '')
        DEPS="$DEPS        .package(path: \"./SubModules/$SUBMODULE_DIR\"),\n"
    done
    
    # Insert dependencies
    sed -i '' "/For testing/a\\
$DEPS" "$MODULE_PATH/Package.swift"
    
    echo "  ✅ Submodules integrated"
}

# Create Projects module
create_module "Projects" "com.bridge.projects"
create_submodules "Projects" "Project Browser" "AI Assistant" "Git Integration" "Build System"

# Create Documents module  
create_module "Documents" "com.bridge.documents"
create_submodules "Documents" "Text Editor" "Markdown Preview" "File Browser" "Search"

# Create Settings module
create_module "Settings" "com.bridge.settings"
create_submodules "Settings" "General" "Appearance" "Modules" "About"

echo -e "\n${GREEN}✨ Module creation complete!${NC}"
echo "=================================="
echo "Created modules:"
echo "  ✅ Projects (with 4 submodules)"
echo "  ✅ Documents (with 4 submodules)"
echo "  ✅ Settings (with 4 submodules)"
echo ""
echo "Note: Terminal module already exists and will use real implementation"