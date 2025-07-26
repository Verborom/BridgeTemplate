# 🔄 Git & Synchronization System Guide

## 📋 **System Overview**

Bridge Template uses a **Staged Manual Git Workflow** (Option 3) for professional development with perfect session continuity.

### **🎯 Core Philosophy:**
- **Manual Control**: All commits require explicit approval
- **Professional Quality**: Meaningful commit messages and logical grouping
- **Safety First**: Review changes before they go public
- **Session Continuity**: Perfect context preservation across Claude sessions

## 🏗️ **Architecture**

### **Local → GitHub Sync Flow:**
```
Local Changes → Git Add → Git Commit → Git Push → GitHub → RAG Update
     ↓              ↓           ↓           ↓          ↓         ↓
  Code Edits    Stage Files   Record     Upload   Triggers   Knowledge
                             Change     Changes   Actions    Update
```

### **Automation Systems:**
- ✅ **Auto-Documentation**: Triggers on every push to main
- ✅ **Session Continuity**: Updates session snapshots automatically  
- ✅ **CI/CD Pipeline**: Tests and validates changes
- ❌ **Auto-Push**: DISABLED for safety and professionalism

## 🛠️ **Daily Usage Patterns**

### **Quick Documentation Updates (30 seconds):**
```bash
# For docs, README, or comment changes
git add docs/ && git commit -m "Update documentation" && git push
```

### **Code Changes (1-2 minutes):**
```bash
# For Swift code, scripts, or configuration
git add .
git commit -m "Add GPU monitoring widget to SystemHealth

- Implement GPUMetrics class with real-time data
- Add temperature and usage display widgets  
- Update component map for granular builds
- Add tests for new functionality"
git push
```

### **Emergency Fixes (45 seconds):**
```bash
# For critical bug fixes
git add specific-file.swift
git commit -m "Fix critical memory leak in ModuleManager"
git push
```

## 📊 **Commit Message Standards**

### **Format:**
```
Brief summary (50 chars or less)

Optional detailed explanation:
- What changed and why
- Impact on other components
- Testing performed
- Breaking changes (if any)
```

### **Examples:**
```bash
# Good commit messages:
"Add GPU temperature monitoring to SystemHealth"
"Fix hot-swap memory leak in ModuleManager" 
"Update component map for infinite nesting support"
"Enhance Intent Parser for better natural language processing"

# Poor commit messages (avoid):
"Updates"
"Fix stuff"
"WIP"
"temp"
```

## 🔧 **Session Continuity Integration**

### **How It Works:**
1. **Every Push** → Triggers GitHub Actions
2. **Session Workflow** → Updates `docs/session-snapshots/current-session.json`
3. **Future Claude Sessions** → Load current context automatically
4. **RAG System** → Gets updated knowledge immediately

### **Session Snapshot Updates:**
- **Automatic**: Updates on every push to main branch
- **Context**: Current development focus, recent changes, next priorities
- **Restoration**: New Claude sessions load complete context instantly

## 🎯 **Best Practices**

### **Commit Frequency:**
- ✅ **Feature Complete**: Commit when logical units of work are done
- ✅ **Working State**: Only commit code that compiles and runs
- ✅ **Meaningful Units**: Group related changes together
- ❌ **Half-Finished**: Don't commit broken or incomplete work

### **Change Grouping:**
```bash
# Group related changes logically:

# Single feature addition:
git add Core/Intelligence/NewParser.swift Modules/Dashboard/Updates.swift
git commit -m "Add advanced natural language parsing for complex requests"

# Documentation updates:
git add docs/ README.md CHANGELOG.md  
git commit -m "Update documentation for new parsing features"

# Bug fixes:
git add Core/ModuleManager/ModuleManager.swift
git commit -m "Fix race condition in hot-swap validation"
```

### **Branch Strategy:**
- **Main Branch**: `main` - Production-ready code only
- **Development**: Work directly on main for this single-developer project
- **Future**: Can add `development` branch if collaboration increases

## 🚨 **Critical Documentation Requirements**

### **MANDATORY: Swift DocC Comments**
Every Swift file MUST have comprehensive documentation comments for auto-documentation:

```swift
/// # ComponentName
/// 
/// Brief description of what this component does.
/// This component supports hot-swapping and independent versioning.
/// 
/// ## Overview
/// Detailed explanation of purpose, functionality, and integration points.
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
    /// Include any important constraints or requirements.
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
- ✅ **Auto-Documentation**: GitHub Actions generates docs from comments
- ✅ **RAG Knowledge**: Well-documented code improves AI understanding
- ✅ **Session Continuity**: New Claude sessions understand components better
- ✅ **Professional Quality**: Maintains high code standards
- ✅ **Future Developers**: Code is self-documenting

### **Documentation Standards:**
1. **Every public class/struct/protocol** must have header documentation
2. **Every public function** must document parameters and return values
3. **Complex logic** should have inline comments explaining why
4. **API changes** must update documentation in same commit
5. **Examples** should be included for non-trivial functionality

## 🔄 **GitHub Actions Integration**

### **Triggered Workflows:**
```yaml
# On every push to main:
documentation-automation.yml   # Updates all docs from code
modular-ci-cd.yml              # Tests affected components
session-continuity.yml         # Updates session snapshots
auto-documentation.yml         # Basic doc generation
module-testing.yml             # Module-specific testing
```

### **What Happens After Push:**
1. **Immediate**: Code uploads to GitHub
2. **30 seconds**: GitHub Actions start processing
3. **2-5 minutes**: Documentation auto-generates
4. **5-10 minutes**: Session snapshots update
5. **Complete**: RAG system has latest knowledge

## 🎮 **Interactive Commands**

### **Status Checking:**
```bash
# Check what's changed locally
git status

# See what will be committed
git diff --staged

# View recent commits
git log --oneline -5

# Check remote status
git remote -v
```

### **Advanced Operations:**
```bash
# Amend last commit (before pushing)
git add forgotten-file.swift
git commit --amend -m "Updated commit message"

# Selective staging
git add specific-file.swift another-file.swift
git commit -m "Focused change description"

# Unstage files
git reset HEAD file-to-unstage.swift
```

## 🚀 **Integration with Development Workflow**

### **Natural Language → Git Workflow:**
1. **Claude Code** builds requested changes
2. **Files modified** according to natural language request
3. **Developer reviews** changes locally
4. **Commit with description** of what was built
5. **Push to GitHub** triggers automation
6. **Documentation updates** automatically
7. **Session continuity** preserved for future Claude sessions

### **Hot-Swap Integration:**
- **Local Testing**: Test hot-swap functionality before committing
- **Version Bumping**: Increment versions in same commit as changes
- **Component Mapping**: Update component maps when adding new components
- **Integration Verification**: Ensure hot-swap still works after changes

## 📈 **Monitoring & Maintenance**

### **Regular Checks:**
- **Weekly**: Review commit history for quality
- **Monthly**: Check documentation coverage
- **Quarterly**: Optimize workflow based on usage patterns

### **Health Indicators:**
- ✅ **All GitHub Actions passing**: Green status on all workflows
- ✅ **Documentation up-to-date**: Auto-generated docs reflect current code
- ✅ **Session snapshots current**: Latest snapshot includes recent work
- ✅ **RAG knowledge fresh**: New Claude sessions understand recent changes

## 🆘 **Troubleshooting**

### **Common Issues:**

#### **Git Authentication Problems:**
```bash
# Check current credentials
git config --list

# Update credentials if needed
git config user.name "Verborom"
git config user.email "joe.lafilm@gmail.com"
```

#### **Push Failures:**
```bash
# Pull latest changes first
git pull origin main

# Resolve conflicts if any
git add .
git commit -m "Resolve merge conflicts"
git push
```

#### **Documentation Not Updating:**
```bash
# Check if GitHub Actions are running
# Visit: https://github.com/Verborom/BridgeTemplate/actions

# Manually trigger if needed
git push  # Should trigger documentation-automation.yml
```

#### **Session Continuity Issues:**
```bash
# Check latest session snapshot
cat docs/session-snapshots/current-session.json

# Verify it's recent (should be within last week)
```

## 🌉 **Future Claude Sessions**

### **Onboarding Integration:**
New Claude sessions will:
1. **Read this guide** to understand git workflow
2. **Check session snapshots** for current project state
3. **Understand commit standards** for professional quality
4. **Know documentation requirements** for auto-generation
5. **Follow established patterns** for consistency

### **Context Restoration:**
- **Complete Git History**: Available via `git log`
- **Current Status**: Via `git status` and session snapshots
- **Recent Changes**: Via `git log --oneline -10`
- **Documentation State**: Via auto-generated docs
- **RAG Knowledge**: Always current with latest pushes

---

**🎯 Summary:** Professional staged manual git workflow with perfect automation integration and session continuity. Every commit is intentional, documented, and automatically enhances the entire ecosystem.
