# Granular Development - Quick Reference

## 🚀 Quick Commands

```bash
# Natural language build
./scripts/smart-build.sh "fix the Add Module button"

# Interactive mode
./scripts/granular-dev.sh

# Direct component build
./scripts/component-builder.sh ui.sidebar.addModule fix
```

## 🎯 Common Targets

### UI Components
- `ui.sidebar.addModule` - Add Module Button
- `ui.navigation.sidebar` - Sidebar Navigation
- `ui.sidebar.moduleRow` - Module Row
- `ui.main.contentArea` - Content Area

### Dashboard Widgets
- `dashboard.widgets.stats` - Statistics Widget
- `dashboard.widgets.activity` - Activity Feed
- `dashboard.widgets.actions` - Quick Actions
- `dashboard.widgets.health` - System Health

### Modules
- `module.dashboard` - Dashboard Module
- `module.projects` - Projects Module
- `module.terminal` - Terminal Module

## ⏱️ Build Times

| Scope | Time | Hot-Swap | Example |
|-------|------|----------|---------|
| Component | 30s | ✅ Yes | Fix button |
| Submodule | 60s | ✅ Yes | Add widget |
| Module | 120s | ✅ Yes | Update module |
| System | 180s | ❌ No | Core changes |
| Full | 300s | ❌ No | Major refactor |

## 📝 Request Patterns

### Fixing Issues
- "fix the [component name]"
- "repair the [feature]"
- "correct the [bug location]"

### Adding Features
- "add [feature] to [location]"
- "create new [component type] for [purpose]"
- "implement [functionality] in [module]"

### Enhancing
- "enhance [component] with [feature]"
- "improve [widget] performance"
- "upgrade [module] to support [capability]"

## 🔍 Scope Decision

```
Button/Tile/Row? → Component (30s)
Widget/Feature? → Submodule (60s)
Entire Module? → Module (120s)
Core System? → System (180s)
```

## ✅ Hot-Swappable
- All UI components
- All dashboard widgets
- Most modules
- No restart needed

## ❌ Requires Restart
- Core protocols
- System managers
- Major architecture changes

## 💡 Pro Tips

1. **Be Specific**: "Add Module button" > "sidebar"
2. **Use Natural Language**: System understands context
3. **Trust the Analyzer**: It knows dependencies
4. **Hot-Swap First**: Try without restart
5. **Test Targeted**: Only affected tests run

## 🆘 Help

```bash
# Show all options
./scripts/granular-dev.sh

# Analyze before building
./scripts/smart-build.sh "analyze ui.sidebar.addModule"

# View component map
cat Core/Intelligence/component-map.json | jq
```