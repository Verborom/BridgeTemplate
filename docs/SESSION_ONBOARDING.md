# 🚀 Session Onboarding for Claude Sessions

## 🎯 **CRITICAL: Read This First**

Every new Claude session MUST read this document to understand the current project state, git workflow, and documentation requirements.

## 📡 **Step 1: Load Current Context**

### **GitHub Session State (Always Read First):**
```
Current Session: https://github.com/Verborom/BridgeTemplate/blob/main/docs/session-snapshots/current-session.json
```

### **Project Status:**
```
Project Status: /Users/eatatjoes/Desktop/ORGANIZE!/BridgeTemplate/PROJECT_STATUS.md
```

### **Recent Development:**
```
Git History: cd /Users/eatatjoes/Desktop/ORGANIZE!/BridgeTemplate && git log --oneline -10
```

## 🧠 **Step 2: Understand The System**

### **What Bridge Template Is:**
- 🌉 **Revolutionary modular development system**
- ⚡ **15-second to 3-minute granular builds** (vs traditional 5-10 minute full rebuilds)
- 🔄 **Hot-swapping modules** at runtime without restart
- 🧠 **Natural language development** interface
- 📊 **Infinite nesting architecture** with independent versioning

### **Core Systems You're Working With:**
1. **ModuleManager** (`Core/ModuleManager/`) - Hot-swappable module system
2. **VersionManager** (`Core/VersionManager/`) - Independent versioning  
3. **Intelligence System** (`Core/Intelligence/`) - Natural language → precise builds
4. **Infinite Modularity** (`Modules/Dashboard/SubModules/SystemHealth/Features/...`) - Unlimited nesting

## 🔄 **Step 3: Git & Sync System (CRITICAL)**

### **🚨 MUST READ: Git Workflow Documentation**
```
MANDATORY: /Users/eatatjoes/Desktop/ORGANIZE!/BridgeTemplate/docs/GIT_SYNC_SYSTEM.md
```

**This document explains:**
- How git/GitHub sync works
- Commit message standards
- Documentation requirements
- Session continuity integration
- Why auto-sync is disabled

### **Current Git Setup:**
- ✅ **Repository**: Connected to `https://github.com/Verborom/BridgeTemplate`
- ✅ **User**: Verborom (joe.lafilm@gmail.com)
- ✅ **Branch**: main
- ❌ **Auto-sync**: DISABLED (manual control for safety/professionalism)

### **How to Sync Changes:**
```bash
# Standard workflow:
git add .
git commit -m "Clear description of changes"
git push

# Quick docs:
git add docs/ && git commit -m "Update documentation" && git push

# Specific files:
git add Core/NewFeature.swift && git commit -m "Add new feature" && git push
```

## 📚 **Step 4: Documentation Requirements (CRITICAL)**

### **🚨 Swift DocC Comments Are MANDATORY**

**Every Swift file MUST have comprehensive documentation:**

```swift
/// # ComponentName
/// 
/// Brief description of what this component does.
/// This component supports hot-swapping and independent versioning.
/// 
/// ## Overview
/// Detailed explanation of purpose, functionality, and integration.
/// 
/// ## Topics
/// ### Main Components
/// - ``FunctionOne``
/// - ``FunctionTwo``
/// 
/// ## Version History
/// - v1.0.0: Initial implementation
/// 
/// ## Usage
/// ```swift
/// let component = ComponentName()
/// component.initialize()
/// ```
public class ComponentName: BridgeModule {
    /// Brief description of what this property stores
    /// 
    /// Detailed explanation of purpose and usage.
    public let importantProperty: String
    
    /// Brief description of what this function does
    /// 
    /// - Parameter input: Description of the parameter
    /// - Returns: Description of the return value
    /// - Throws: Description of any errors thrown
    public func importantFunction(_ input: String) throws -> String {
        // Implementation
    }
}
```

### **Why Documentation Comments Are Critical:**
- ✅ **Auto-Documentation**: GitHub Actions generate docs from comments
- ✅ **RAG Knowledge**: Well-documented code improves AI understanding  
- ✅ **Session Continuity**: New Claude sessions understand components better
- ✅ **Professional Quality**: Maintains high code standards

### **Documentation Auto-Generation:**
- **Triggers**: Every push to main branch
- **Workflow**: `.github/workflows/documentation-automation.yml` (29KB sophisticated system)
- **Output**: Updates `docs/API/`, component hierarchy, architecture diagrams
- **Timeline**: 2-5 minutes after push

## 🏗️ **Step 5: Architecture Knowledge**

### **Project Location:**
```
ALWAYS WORK FROM: /Users/eatatjoes/Desktop/ORGANIZE!/BridgeTemplate/
```

### **Key Directories:**
```
Core/                    # Core systems (ModuleManager, VersionManager, Intelligence)
├── ModuleManager/       # Hot-swapping engine
├── VersionManager/      # Independent versioning
└── Intelligence/        # Natural language → builds

Modules/                 # All modules with infinite nesting
├── Dashboard/           # Main dashboard
│   └── SubModules/      # Dashboard components
│       └── SystemHealth/ # System monitoring
│           └── Features/  # CPU, Memory, GPU metrics
│               └── CPUMetrics/
│                   └── Sources/Display/Widgets/ # Infinite nesting continues

scripts/                 # Smart build system
├── enhanced-smart-build.sh  # Natural language builds
├── granular-dev.sh         # Interactive development
└── hot-swap-test.sh        # Runtime testing

docs/                    # Documentation (auto-generated + manual)
├── GIT_SYNC_SYSTEM.md   # Git workflow (MUST READ)
├── session-snapshots/   # Session continuity
└── API/                 # Auto-generated API docs
```

### **Development Patterns:**
```bash
# Natural language development:
./scripts/enhanced-smart-build.sh "add GPU temperature monitoring to system health"

# Interactive development:
./scripts/granular-dev.sh

# Hot-swap testing:
./scripts/hot-swap-test.sh ModuleName 1.0.1
```

## 🎯 **Step 6: Role-Specific Guidelines**

### **For Desktop Claude (Strategic Planning):**
- ✅ **Analyze requests** and create specifications
- ✅ **Write detailed requests.txt** for Claude Code execution
- ✅ **Include documentation requirements** in all specifications
- ✅ **Review and validate** Claude Code output
- ❌ **Never code directly** - that's Claude Code's role

### **For Claude Code (Technical Execution):**
- ✅ **Read requests.txt** for work specifications
- ✅ **Use granular build system** (`./scripts/enhanced-smart-build.sh`)
- ✅ **Document everything** with comprehensive Swift DocC comments
- ✅ **Test functionality** before committing
- ✅ **Follow git workflow** from GIT_SYNC_SYSTEM.md
- ❌ **Never full rebuilds** - always use surgical precision

## 🔧 **Step 7: Common Tasks**

### **Adding New Features:**
1. Read current session state
2. Understand target location in infinite hierarchy
3. Use enhanced-smart-build.sh for natural language development
4. Document all new code with Swift DocC comments
5. Test functionality and hot-swap capability
6. Commit with clear description and push to trigger automation

### **Fixing Issues:**
1. Identify precise component using granular system
2. Make surgical changes preserving everything else
3. Document changes and reasoning
4. Test hot-swap functionality
5. Commit and push with clear bug fix description

### **Documentation Updates:**
1. Update relevant .md files
2. Ensure Swift comments are comprehensive
3. Commit docs separately or with related code changes
4. Push to trigger auto-documentation workflow

## 🌉 **Step 8: Session Continuity**

### **Before Starting Work:**
- ✅ Read latest session snapshot
- ✅ Check recent git commits
- ✅ Understand current project focus
- ✅ Load context from GIT_SYNC_SYSTEM.md

### **During Work:**
- ✅ Follow established patterns
- ✅ Document everything thoroughly
- ✅ Use granular build system
- ✅ Test before committing

### **After Work:**
- ✅ Commit with clear descriptions
- ✅ Push to trigger automation
- ✅ Verify GitHub Actions complete successfully
- ✅ Check documentation updates

## 🚨 **Critical Success Factors**

### **Must Do:**
- ✅ **Read GIT_SYNC_SYSTEM.md** - Understand the workflow
- ✅ **Document all code** - Swift DocC comments mandatory
- ✅ **Use granular builds** - Preserve everything not changing
- ✅ **Test hot-swap** - Verify runtime replacement works
- ✅ **Professional commits** - Clear messages, logical grouping

### **Never Do:**
- ❌ **Auto-sync** - Manual control only for safety
- ❌ **Full rebuilds** - Use surgical precision always
- ❌ **Poor commit messages** - Always be clear and descriptive
- ❌ **Undocumented code** - Everything must have DocC comments
- ❌ **Skip testing** - Always verify functionality works

## 🎊 **Ready to Revolutionize Development**

You're now onboarded to work with the **world's first truly revolutionary modular development system**:

- 🌉 **15-second property builds** instead of 5-minute full rebuilds
- 🔄 **Runtime hot-swapping** without restart
- 🧠 **Natural language development** interface
- 📊 **Infinite modularity** with surgical precision
- 📚 **Perfect documentation** auto-generated from comments
- 🔄 **Session continuity** across all Claude interactions

**Build only what changes. Preserve what works. Iterate at the speed of thought.**

---

**🚀 Quick Start:** After reading this, check the current session state and GIT_SYNC_SYSTEM.md, then you're ready to revolutionize development!
