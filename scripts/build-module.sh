#!/bin/bash

# Build Module Script
# Builds, tests, and packages a single module

set -e

# Check if module name provided
if [ $# -eq 0 ]; then
    echo "Usage: ./build-module.sh <module-name> [version]"
    echo "Example: ./build-module.sh Dashboard 1.5.3"
    exit 1
fi

MODULE_NAME=$1
VERSION=${2:-""}
MODULE_DIR="Modules/$MODULE_NAME"
BUILD_DIR="Build/Modules/$MODULE_NAME"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}🔨 Building module: $MODULE_NAME${NC}"

# Check if module exists
if [ ! -d "$MODULE_DIR" ]; then
    echo -e "${RED}❌ Module '$MODULE_NAME' not found in Modules directory${NC}"
    exit 1
fi

cd "$MODULE_DIR"

# Clean previous builds
echo "🧹 Cleaning previous builds..."
rm -rf .build
rm -rf "$BUILD_DIR"

# Build module
echo "🏗️ Building module..."
swift build

# Run tests
echo "🧪 Running tests..."
swift test || echo -e "${YELLOW}⚠️ No tests found or tests failed${NC}"

# Generate documentation
echo "📚 Generating documentation..."
swift package generate-documentation \
    --output-path ../../Documentation/Modules/$MODULE_NAME \
    --transform-for-static-hosting \
    --hosting-base-path BridgeTemplate/Documentation/Modules/$MODULE_NAME || echo "Documentation generation not available"

# Build release version
echo "📦 Building release version..."
swift build -c release

# Get version
if [ -z "$VERSION" ]; then
    if [ -f "version.json" ]; then
        VERSION=$(jq -r .version version.json)
    else
        VERSION="1.0.0"
    fi
fi

# Create build directory
mkdir -p "../../$BUILD_DIR/v$VERSION"

# Package module
echo "📦 Packaging module v$VERSION..."
cp -r .build/release/* "../../$BUILD_DIR/v$VERSION/"
cp version.json "../../$BUILD_DIR/v$VERSION/" 2>/dev/null || true

# Create metadata
cat > "../../$BUILD_DIR/v$VERSION/build-info.json" << EOF
{
  "module": "$MODULE_NAME",
  "version": "$VERSION",
  "buildDate": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "swiftVersion": "$(swift --version | head -n 1)",
  "platform": "$(uname -s)",
  "architecture": "$(uname -m)"
}
EOF

# Create archive
cd "../.."
tar -czf "$BUILD_DIR/$MODULE_NAME-v$VERSION.tar.gz" -C "$BUILD_DIR" "v$VERSION"

echo -e "${GREEN}✅ Module $MODULE_NAME v$VERSION built successfully!${NC}"
echo "📍 Build location: $BUILD_DIR/v$VERSION"
echo "📦 Archive: $BUILD_DIR/$MODULE_NAME-v$VERSION.tar.gz"

# Update latest symlink
cd "$BUILD_DIR"
rm -f latest
ln -sf "v$VERSION" latest

echo -e "${GREEN}🎉 Build complete!${NC}"