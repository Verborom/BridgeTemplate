#!/bin/bash

# Generate Documentation Script
# Generates comprehensive documentation for all modules

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}📚 Bridge Template Documentation Generator${NC}"
echo "=========================================="

# Create documentation structure
echo "📁 Creating documentation structure..."
mkdir -p Documentation/Architecture
mkdir -p Documentation/Modules
mkdir -p Documentation/API
mkdir -p Documentation/Guides

# Generate architecture documentation
echo "🏗️ Generating architecture documentation..."
cat > Documentation/Architecture/README.md << 'EOF'
# Bridge Template Architecture

## Overview
Bridge Template implements a revolutionary modular architecture enabling:
- **Infinite Modularity**: Modules can contain modules recursively
- **Hot-Swapping**: Replace modules at runtime without restart
- **Independent Versioning**: Each module has its own version lifecycle
- **Auto-Documentation**: Code comments generate beautiful docs

## Core Components

### ModuleManager
The heart of the system, managing module lifecycle and communication.

### VersionManager
Tracks versions, dependencies, and compatibility across modules.

### BridgeModule Protocol
The contract every module must implement for hot-swapping.

## Module Structure
```
Module/
├── Package.swift      # Swift package definition
├── Sources/          # Module source code
├── Tests/           # Module tests
├── Documentation/   # Auto-generated docs
├── version.json     # Version metadata
└── SubModules/      # Nested modules
```
EOF

# Generate module documentation index
echo "📖 Generating module documentation..."
cat > Documentation/Modules/README.md << 'EOF'
# Bridge Template Modules

## Available Modules

### Dashboard (v1.5.2)
Real-time project statistics and activity monitoring.
- **StatsWidget** (v1.2.1): Animated statistics cards
- **ActivityFeed** (v1.3.0): Live activity streaming
- **QuickActions** (v1.1.0): Customizable action buttons
- **SystemHealth** (v1.0.3): System monitoring

### Projects (v1.8.1)
Project management with drag-and-drop interface.

### Terminal (v1.2.0)
Integrated development terminal.

## Module Development Guide
See [Module Development Guide](../Guides/module-development.md)
EOF

# Generate development guide
echo "📝 Creating development guides..."
cat > Documentation/Guides/module-development.md << 'EOF'
# Module Development Guide

## Creating a New Module

1. **Create Module Structure**
   ```bash
   ./scripts/create-module.sh MyModule
   ```

2. **Implement BridgeModule Protocol**
   ```swift
   class MyModule: BridgeModule {
       let id = "com.bridge.mymodule"
       let displayName = "My Module"
       let icon = "star.fill"
       let version = ModuleVersion(major: 1, minor: 0, patch: 0)
       
       // Implementation...
   }
   ```

3. **Add Documentation**
   Every public API must have comprehensive documentation comments.

4. **Test Your Module**
   ```bash
   ./scripts/build-module.sh MyModule
   ```

5. **Hot-Swap Testing**
   ```bash
   ./scripts/hot-swap-test.sh MyModule 1.0.0
   ```

## Best Practices
- Keep modules focused and single-purpose
- Document all public APIs
- Version semantically
- Test hot-swapping scenarios
- Handle cleanup properly
EOF

# Generate API documentation landing page
echo "🔌 Creating API documentation index..."
cat > Documentation/API/README.md << 'EOF'
# Bridge Template API Documentation

## Core APIs
- [BridgeModule Protocol](Core/BridgeModule)
- [ModuleManager](Core/ModuleManager)
- [VersionManager](Core/VersionManager)

## Module APIs
- [Dashboard Module](Modules/Dashboard)
- [Projects Module](Modules/Projects)
- [Terminal Module](Modules/Terminal)

## Auto-Generated Documentation
This documentation is automatically generated from code comments using Swift DocC.
Updates happen automatically when code is pushed to the repository.
EOF

# Generate main documentation index
echo "📑 Creating main documentation index..."
cat > Documentation/README.md << 'EOF'
# Bridge Template Documentation

Welcome to the Bridge Template documentation!

## Quick Links
- [Architecture Overview](Architecture/README.md)
- [Module Catalog](Modules/README.md)
- [API Reference](API/README.md)
- [Development Guides](Guides/module-development.md)

## Getting Started
1. Read the [Architecture Overview](Architecture/README.md)
2. Explore [Available Modules](Modules/README.md)
3. Learn [Module Development](Guides/module-development.md)

## Key Features
- 🔄 **Hot-Swapping**: Replace modules without restart
- 📦 **Independent Versioning**: Each module versions separately
- 🔗 **Infinite Modularity**: Modules can contain modules
- 📚 **Auto-Documentation**: Generated from code comments
- 🧪 **Automated Testing**: Per-module CI/CD

## Documentation Updates
This documentation is automatically updated when:
- Code is pushed to the repository
- Modules are added or updated
- API changes are detected

Last Updated: $(date -u +%Y-%m-%dT%H:%M:%SZ)
EOF

echo -e "${GREEN}✅ Documentation generation complete!${NC}"
echo "📍 Documentation location: Documentation/"
echo ""
echo "Next steps:"
echo "1. Review generated documentation"
echo "2. Push to repository to trigger auto-documentation"
echo "3. View live docs at GitHub Pages"