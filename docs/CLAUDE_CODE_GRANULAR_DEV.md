# Claude Code - Granular Development Guidelines

## 🧠 CRITICAL: Always Determine Build Scope

The Bridge Template project now features a **Granular Development Intelligence System** that enables targeted component building without full rebuilds. This dramatically reduces build times and preserves existing functionality.

### Before Building ANYTHING, You Must:

1. **Parse the Request**: Understand what specifically needs to change
2. **Check Component Map**: Look up the exact files and scope
3. **Analyze Dependencies**: What else might be affected
4. **Confirm Scope**: Ask if unclear between component/submodule/module

## 📊 Build Scope Levels

### 1. Component (30-60s)
- **Scope**: Single UI element or function
- **Examples**: Buttons, tiles, navigation elements
- **Hot-Swappable**: Yes
- **Restart Required**: No

### 2. Submodule (45-90s)
- **Scope**: Feature within a module
- **Examples**: Dashboard widgets, module features
- **Hot-Swappable**: Yes
- **Restart Required**: No

### 3. Module (90-180s)
- **Scope**: Entire module
- **Examples**: Dashboard, Projects, Terminal
- **Hot-Swappable**: Usually
- **Restart Required**: Sometimes

### 4. System (3-5 min)
- **Scope**: Core architecture
- **Examples**: ModuleManager, BridgeModule protocol
- **Hot-Swappable**: No
- **Restart Required**: Yes

### 5. Full (5-10 min)
- **Scope**: Complete rebuild
- **When**: Only for major architectural changes
- **Hot-Swappable**: No
- **Restart Required**: Yes

## 🎯 Request Analysis Examples

### Example 1: "Fix the Add Module button"
```
Target: ui.sidebar.addModule  
Scope: component
Files: 
  - Platforms/macOS/BridgeMac.swift
  - Platforms/macOS/UI/ModuleSelectorView.swift
Preserve: All modules, all other UI components
Build Time: ~30 seconds
```

### Example 2: "Add Feature21 to Dashboard"
```
Target: dashboard.submodules.feature21
Scope: submodule
Files: 
  - Modules/Dashboard/SubModules/Feature21/
Preserve: All other dashboard widgets, all other modules
Build Time: ~60 seconds
```

### Example 3: "Create sidebar tile for system status"
```
Target: ui.sidebar.systemStatus (new)
Scope: component  
Files: New component in UI/SidebarTiles/
Preserve: All existing sidebar functionality
Build Time: ~45 seconds
```

### Example 4: "Enhance stats widget with real-time data"
```
Target: dashboard.widgets.stats
Scope: submodule
Files:
  - Modules/Dashboard/SubModules/StatsWidget/
  - Core/MockModules.swift (stats section only)
Preserve: All other widgets and modules
Build Time: ~45 seconds
```

## 🛠️ Using the Granular Development System

### Smart Build Command
```bash
./scripts/smart-build.sh "your natural language request"
```

### Interactive Mode
```bash
./scripts/granular-dev.sh
```

### Direct Component Build
```bash
./scripts/component-builder.sh ui.sidebar.addModule fix
```

## 📋 Decision Tree for Build Scope

```
Is it a UI element (button, tile, row)?
  └─ YES → Component scope
  └─ NO → Continue...
  
Is it a widget or feature within a module?
  └─ YES → Submodule scope
  └─ NO → Continue...
  
Is it an entire module (Dashboard, Projects)?
  └─ YES → Module scope
  └─ NO → Continue...
  
Is it core infrastructure (protocols, managers)?
  └─ YES → System scope
  └─ NO → Component scope (default)
```

## ⚡ Hot-Swapping Guidelines

### Supported for Hot-Swap:
- ✅ UI Components
- ✅ Dashboard Widgets
- ✅ Module Features
- ✅ Most Modules

### NOT Supported for Hot-Swap:
- ❌ Core protocols (BridgeModule)
- ❌ System managers (ModuleManager)
- ❌ Version management
- ❌ Build infrastructure

## 🔍 Component Mapping Reference

The system uses `Core/Intelligence/component-map.json` to track:
- Component identifiers
- Associated files
- Dependencies
- Build times
- Hot-swap capability

### Quick Lookup:
```json
"ui.sidebar.addModule": {
  "files": ["Platforms/macOS/BridgeMac.swift"],
  "buildScope": "component",
  "buildTime": 30,
  "hotSwappable": true
}
```

## 📝 Best Practices

### 1. Always Start Specific
Instead of: "Fix the sidebar"
Use: "Fix the Add Module button in the sidebar"

### 2. Preserve by Default
The system automatically preserves everything not explicitly targeted.

### 3. Test After Build
Component builds include targeted tests:
```bash
swift test --filter ComponentNameTests
```

### 4. Use Hot-Swap When Possible
If a component supports hot-swapping, the system will automatically apply changes without restart.

## 🚨 Common Pitfalls to Avoid

### ❌ DON'T: Rebuild Everything
```bash
# Bad: Full rebuild for button fix
./scripts/build-v2.0.1.sh
```

### ✅ DO: Build Only What's Needed
```bash
# Good: Component-specific build
./scripts/smart-build.sh "fix the Add Module button"
```

### ❌ DON'T: Guess the Scope
If unsure, the system will ask for clarification.

### ✅ DO: Let Intelligence Guide You
The system analyzes dependencies and suggests the minimal scope.

## 🎯 Example Workflow

**User**: "Let's add a CPU usage monitor to the dashboard"

**Claude Code Analysis**:
1. Parse: New widget for dashboard
2. Target: `dashboard.widgets.cpuMonitor`
3. Scope: submodule
4. Action: add/create

**Execution**:
```bash
./scripts/smart-build.sh "add CPU usage monitor to dashboard"
# Builds only the new widget (60s)
# Hot-swaps into running dashboard
# No restart required
```

## 📊 Performance Comparison

| Traditional | Granular | Improvement |
|------------|----------|-------------|
| Full rebuild (5 min) | Component (30s) | 10x faster |
| Module rebuild (2 min) | Submodule (45s) | 2.7x faster |
| Restart required | Hot-swap | No downtime |

## 🔧 Troubleshooting

### "Target not specific enough"
- Add more detail to your request
- Use component browser: `./scripts/granular-dev.sh`

### "Component not found"
- Check `component-map.json` for valid identifiers
- May need to create new component entry

### "Hot-swap failed"
- Component may not support hot-swapping
- Check if app restart is required

## 🚀 Summary

The Granular Development Intelligence System enables:
- **Targeted builds** - Build only what changes
- **Faster iteration** - 30s instead of 5 minutes
- **Zero downtime** - Hot-swap without restart
- **Natural language** - Describe what you want
- **Intelligent scope** - System determines minimal build

This is the future of modular development - build smarter, not harder!