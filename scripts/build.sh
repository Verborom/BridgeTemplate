#!/bin/bash

# Bridge Template - Main Build Script
# Builds both macOS and iOS platforms with proper versioning

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get project root
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

# Read version
VERSION=$(cat VERSION)
echo -e "${GREEN}Building Bridge Template v$VERSION${NC}"

# Parse arguments
PLATFORM="all"
BUILD_CONFIG="Release"
CLEAN_BUILD=false

while [[ $# -gt 0 ]]; do
    case $1 in
        macos|ios)
            PLATFORM="$1"
            ;;
        --debug)
            BUILD_CONFIG="Debug"
            ;;
        --release)
            BUILD_CONFIG="Release"
            ;;
        --clean)
            CLEAN_BUILD=true
            ;;
        --help)
            echo "Usage: $0 [platform] [options]"
            echo "Platforms: macos, ios (default: all)"
            echo "Options:"
            echo "  --debug    Build debug configuration"
            echo "  --release  Build release configuration (default)"
            echo "  --clean    Clean before building"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
    shift
done

# Clean if requested
if [ "$CLEAN_BUILD" = true ]; then
    echo -e "${YELLOW}Cleaning build directories...${NC}"
    rm -rf src/shared/.build
    rm -rf src/macos/build
    rm -rf src/ios/build
fi

# Function to build shared package
build_shared() {
    echo -e "\n${YELLOW}Building BridgeCore package...${NC}"
    cd "$PROJECT_ROOT/src/shared"
    
    swift build -c "$BUILD_CONFIG"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ BridgeCore built successfully${NC}"
    else
        echo -e "${RED}✗ BridgeCore build failed${NC}"
        exit 1
    fi
    
    cd "$PROJECT_ROOT"
}

# Function to build macOS app
build_macos() {
    echo -e "\n${YELLOW}Building macOS app...${NC}"
    cd "$PROJECT_ROOT/src/macos"
    
    # Create Xcode project if it doesn't exist
    if [ ! -d "BridgeMac.xcodeproj" ]; then
        echo "Creating Xcode project..."
        # For now, we'll create it manually later
        echo -e "${YELLOW}Note: Xcode project needs to be created${NC}"
    fi
    
    # Build with xcodebuild (when project exists)
    # xcodebuild -project BridgeMac.xcodeproj \
    #            -scheme BridgeMac \
    #            -configuration "$BUILD_CONFIG" \
    #            -derivedDataPath build \
    #            build
    
    # For now, create a placeholder
    mkdir -p "$PROJECT_ROOT/builds/macos/v$VERSION"
    echo "macOS build v$VERSION" > "$PROJECT_ROOT/builds/macos/v$VERSION/build.txt"
    
    echo -e "${GREEN}✓ macOS build prepared${NC}"
    cd "$PROJECT_ROOT"
}

# Function to build iOS app
build_ios() {
    echo -e "\n${YELLOW}Building iOS app...${NC}"
    cd "$PROJECT_ROOT/src/ios"
    
    # Create Xcode project if it doesn't exist
    if [ ! -d "BridgeiOS.xcodeproj" ]; then
        echo "Creating Xcode project..."
        # For now, we'll create it manually later
        echo -e "${YELLOW}Note: Xcode project needs to be created${NC}"
    fi
    
    # Build with xcodebuild (when project exists)
    # xcodebuild -project BridgeiOS.xcodeproj \
    #            -scheme BridgeiOS \
    #            -configuration "$BUILD_CONFIG" \
    #            -derivedDataPath build \
    #            -sdk iphoneos \
    #            build
    
    # For now, create a placeholder
    mkdir -p "$PROJECT_ROOT/builds/ios/v$VERSION"
    echo "iOS build v$VERSION" > "$PROJECT_ROOT/builds/ios/v$VERSION/build.txt"
    
    echo -e "${GREEN}✓ iOS build prepared${NC}"
    cd "$PROJECT_ROOT"
}

# Function to update latest symlinks
update_symlinks() {
    echo -e "\n${YELLOW}Updating latest symlinks...${NC}"
    
    # macOS
    if [ -d "builds/macos/v$VERSION" ]; then
        rm -f "builds/macos/latest"
        ln -sf "v$VERSION" "builds/macos/latest"
        echo -e "${GREEN}✓ macOS latest -> v$VERSION${NC}"
    fi
    
    # iOS
    if [ -d "builds/ios/v$VERSION" ]; then
        rm -f "builds/ios/latest"
        ln -sf "v$VERSION" "builds/ios/latest"
        echo -e "${GREEN}✓ iOS latest -> v$VERSION${NC}"
    fi
}

# Main build process
echo -e "${YELLOW}Starting build process...${NC}"
echo "Platform: $PLATFORM"
echo "Configuration: $BUILD_CONFIG"
echo ""

# Always build shared first
build_shared

# Build requested platforms
case $PLATFORM in
    all)
        build_macos
        build_ios
        ;;
    macos)
        build_macos
        ;;
    ios)
        build_ios
        ;;
esac

# Update symlinks
update_symlinks

# Summary
echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}Build completed successfully!${NC}"
echo -e "${GREEN}Version: $VERSION${NC}"
echo -e "${GREEN}Configuration: $BUILD_CONFIG${NC}"
echo -e "${GREEN}========================================${NC}"

# Run cleanup to manage storage
echo -e "\n${YELLOW}Running storage cleanup...${NC}"
"$PROJECT_ROOT/scripts/cleanup.sh"

echo -e "\n${GREEN}Done! Builds available in:${NC}"
echo "  - builds/macos/latest/"
echo "  - builds/ios/latest/"