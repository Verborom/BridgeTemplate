#!/bin/bash

# Customize a submodule created from UniversalTemplate
# Usage: ./CustomizeSubmodule.sh <path> <name> <identifier>

SUBMODULE_PATH=$1
SUBMODULE_NAME=$2
SUBMODULE_ID=$3

echo "Customizing submodule: $SUBMODULE_NAME at $SUBMODULE_PATH"

# Update Package.swift
sed -i '' "s/UniversalTemplate/$SUBMODULE_NAME/g" "$SUBMODULE_PATH/Package.swift"
sed -i '' "s/com.bridge.universal/$SUBMODULE_ID/g" "$SUBMODULE_PATH/Package.swift"

# Update README.md
sed -i '' "s/UniversalTemplate/$SUBMODULE_NAME/g" "$SUBMODULE_PATH/README.md"

# Rename source directory
if [ -d "$SUBMODULE_PATH/Sources/UniversalTemplate" ]; then
    mv "$SUBMODULE_PATH/Sources/UniversalTemplate" "$SUBMODULE_PATH/Sources/$SUBMODULE_NAME"
fi

# Rename test directory
if [ -d "$SUBMODULE_PATH/Tests/UniversalTemplateTests" ]; then
    mv "$SUBMODULE_PATH/Tests/UniversalTemplateTests" "$SUBMODULE_PATH/Tests/${SUBMODULE_NAME}Tests"
fi

# Update CICD workflow
if [ -f "$SUBMODULE_PATH/CICD/Workflows/universal-component.yml" ]; then
    sed -i '' "s/UniversalTemplate/$SUBMODULE_NAME/g" "$SUBMODULE_PATH/CICD/Workflows/universal-component.yml"
    sed -i '' "s/HierarchyLevel.module/HierarchyLevel.submodule/g" "$SUBMODULE_PATH/CICD/Workflows/universal-component.yml"
fi

echo "✅ Customization complete for $SUBMODULE_NAME"