# Dynamic Module Discovery System

## Overview

The Bridge Template now features a fully dynamic module discovery system that automatically finds and loads modules from the file system, eliminating the need for hardcoded module instantiation.

## 🚀 Key Features

### 1. **Automatic Module Discovery**
- Scans the `Modules/` directory at runtime
- Identifies valid modules by checking for:
  - `Package.swift` file
  - `Sources/` directory
  - Module implementation files (`*Module.swift`)
- Extracts metadata directly from source files

### 2. **Dynamic Module Loading**
- No compile-time dependencies on specific modules
- Modules can be added/removed without modifying core code
- Maintains hot-swapping capability
- Preserves version management

### 3. **Universal Component Support**
- `UniversalModuleAdapter` bridges UniversalTemplate modules to BridgeModule protocol
- Seamless integration of modules using different architectures
- Supports infinite nesting through UniversalComponent hierarchy

## 📁 Implementation Details

### Core Components

#### `ModuleDiscovery.swift`
- Main discovery engine
- Scans file system for modules
- Parses module metadata from source files
- Creates module instances dynamically

#### `UniversalModuleAdapter.swift`
- Adapter pattern implementation
- Converts UniversalComponent to BridgeModule
- Maintains protocol compatibility
- Handles message translation

#### Updated `ModuleManager.swift`
- Uses `ModuleDiscovery` instead of hardcoded modules
- Dynamic instantiation based on discovered modules
- Improved error handling for missing modules

## 🔧 Module Requirements

For a module to be discovered automatically, it must:

1. **Be located in the `Modules/` directory**
2. **Have a valid `Package.swift` file**
3. **Contain a `Sources/` directory**
4. **Include a module implementation file** (e.g., `DashboardModule.swift`)
5. **Define required metadata in the implementation**:
   - `id` (identifier like "com.bridge.modulename")
   - `displayName`
   - `version`
   - `icon`

## 📊 Current Modules

The system successfully discovers all 6 modules:

1. **Dashboard** - Project statistics and activity monitoring
2. **Documents** - Document management with UniversalTemplate
3. **PersonalAssistant** - AI-powered assistant with submodules
4. **Projects** - Project management system
5. **Settings** - Application configuration
6. **Terminal** - Full terminal with Claude Code integration (v1.3.0)

## 🔄 Migration Guide

### From Hardcoded to Dynamic

**Before** (hardcoded):
```swift
private func createModuleInstance(from metadata: ModuleMetadata) async throws -> any BridgeModule {
    switch metadata.identifier {
    case "com.bridge.dashboard":
        return DashboardModule()
    case "com.bridge.terminal":
        return TerminalModule()
    default:
        throw ModuleError.initializationFailed("Unknown module")
    }
}
```

**After** (dynamic):
```swift
private func createModuleInstance(from metadata: ModuleMetadata) async throws -> any BridgeModule {
    let discoveredModule = discoveredModules.first { $0.identifier == metadata.identifier }
    return try await moduleDiscovery.createModuleInstance(from: discoveredModule)
}
```

## 🧪 Testing

Run the test script to verify discovery:
```bash
./scripts/test-dynamic-discovery.swift
```

Build with dynamic discovery:
```bash
./scripts/build-dynamic-discovery.sh
```

## ✅ Benefits

1. **True Modularity** - Add modules without touching core code
2. **Reduced Coupling** - No compile-time dependencies between core and modules
3. **Easier Development** - Module developers work independently
4. **Better Scalability** - System grows without complexity
5. **Maintained Features** - Hot-swapping, versioning, and all existing features preserved

## 🚨 Important Notes

### Terminal Module Integration

The Terminal module (v1.3.0) is now properly integrated with:
- Real shell processes and PTY support
- Claude Code integration with automated onboarding
- Auto-permission system for unattended execution
- Multi-session support with tabs
- Full ANSI color and escape sequence support

### UniversalTemplate Modules

Modules built with UniversalTemplate (Documents, PersonalAssistant, Settings, Projects) are automatically adapted to work with the BridgeModule protocol through the `UniversalModuleAdapter`.

## 🎯 Future Enhancements

1. **Plugin System** - Load modules from external packages
2. **Module Marketplace** - Download and install modules dynamically
3. **Dependency Resolution** - Automatic dependency installation
4. **Version Management** - Support multiple versions of same module
5. **Security Sandboxing** - Isolate module execution

---

The dynamic module discovery system represents a major architectural improvement, enabling true modularity and extensibility in Bridge Template.