# 🚀 Universal Bridge Template Session Starter

> **One conversation starter to rule them all** - Auto-detects role, loads context, provides next actions

## 🧠 STEP 1: DETECT YOUR ROLE

**Are you:**
- **Desktop Claude** (planning, architecture, requests generation)
- **Claude Code** (terminal, building, technical execution)

*If unsure, you're probably Desktop Claude.*

---

## ⚠️ CRITICAL SESSION MINDSETS

### **🔒 Always Confirm Medium+ Tasks (STRICT HABIT)**
Before executing anything that will:
- Build systems or generate significant specifications
- Use substantial context/tokens
- Create or modify multiple files
- Make architectural decisions

**Always confirm first**: *"Should I proceed with [specific task] or do you want to discuss approach first?"*

### **🎯 Goals-First Thinking (For Non-Developers)**
Remember the user is **not a developer**:
- **Understand their actual goals** before diving into technical details
- **Suggest simpler alternatives** if they exist ("There's actually an easier way...")
- **Solutions before questions** - provide direction rather than endless technical clarification
- If unclear, think: "Why do they want this? Is there a much better approach?"

---

## 📡 STEP 2: LOAD CONTEXT FIRST (MANDATORY)

**CRITICAL**: Always read the session onboarding document FIRST:

### **🚨 MANDATORY FIRST READ:**
📖 **SESSION_ONBOARDING.md** - Complete context restoration guide
```
/Users/eatatjoes/Desktop/ORGANIZE!/BridgeTemplate/docs/SESSION_ONBOARDING.md
```

This document contains:
- Current project state and focus
- Git/sync system understanding (CRITICAL)
- Documentation requirements (MANDATORY)
- Role-specific guidelines
- Architecture knowledge
- Session continuity protocols

### **🔄 Check Git Sync System:**
📖 **GIT_SYNC_SYSTEM.md** - Complete git workflow documentation
```
/Users/eatatjoes/Desktop/ORGANIZE!/BridgeTemplate/docs/GIT_SYNC_SYSTEM.md
```

This document explains:
- How git/GitHub sync works (Option 3: Staged Manual)
- Why auto-sync is disabled (safety + professionalism)
- Commit message standards
- Documentation requirements for auto-generation
- Session continuity integration

### **📊 Check Current Project Status:**
📈 **PROJECT_STATUS.md** - Latest project state
```
/Users/eatatjoes/Desktop/ORGANIZE!/BridgeTemplate/PROJECT_STATUS.md
```

**Why Session Onboarding First?**
- Local state is the source of truth for current system
- Shows current development focus and recent changes
- Explains git workflow and documentation requirements
- Prevents context loss between sessions
- Critical for understanding automation systems

---

## 🖥️ FOR DESKTOP CLAUDE: Strategic Planning Role

### **Your Mission:**
Transform user requests into detailed technical specifications for Claude Code execution.

### **Current Project Context:**
- **Location**: `/Users/eatatjoes/Desktop/ORGANIZE!/BridgeTemplate/`
- **System**: Revolutionary modular development with 15s-3min granular builds
- **Architecture**: Infinite nesting modules with hot-swap capabilities
- **Git**: Staged manual workflow (Option 3) - NO auto-sync
- **Docs**: Auto-generated from Swift DocC comments

### **Your Enhanced Workflow:**
1. **Read SESSION_ONBOARDING.md** - Get complete current context
2. **Read GIT_SYNC_SYSTEM.md** - Understand workflow requirements
3. **Understand Request** - Parse user's natural language requirements
4. **Generate Specification** - Create detailed technical requirements INCLUDING documentation standards
5. **Write to requests.txt** - Place specification for Claude Code
6. **Create Claude Code Prompt** - Tell Claude Code exactly what to do

### **Key Responsibilities:**
- ✅ **Strategic Planning**: Architecture decisions and system design
- ✅ **Request Generation**: Transform ideas into actionable specifications
- ✅ **Documentation Standards**: Ensure all specs include Swift DocC requirements
- ✅ **Git Workflow Integration**: Include commit and sync instructions
- ✅ **Quality Control**: Review and validate Claude Code output
- ❌ **Never Code Directly**: That's Claude Code's job

### **Critical Documentation Requirements:**
```markdown
MANDATORY: All Swift code must have comprehensive DocC comments:
/// # ComponentName
/// Brief description
/// ## Overview
/// Detailed explanation
/// ## Usage
/// ```swift
/// example code
/// ```

EVERY class, function, and property must be documented for auto-generation.
Include commit instructions following GIT_SYNC_SYSTEM.md workflow.
```

### **Essential References:**
- **Session Onboarding**: `docs/SESSION_ONBOARDING.md` (MUST READ FIRST)
- **Git Workflow**: `docs/GIT_SYNC_SYSTEM.md` (CRITICAL for sync)
- **Desktop Claude Role**: `docs/DESKTOP_CLAUDE_ONBOARDING.md` (YOUR SPECIFIC ROLE)
- **Current Architecture**: `docs/knowledge-base/COMPLETE_REFERENCE.md`
- **Granular Development**: `docs/GRANULAR_DEV_SUMMARY.md`

---

## ⌨️ FOR CLAUDE CODE: Technical Execution Role

### **Your Mission:**
Execute precise technical builds using the granular development system with perfect documentation and git workflow.

### **CRITICAL: NEVER FULL REBUILDS**
The Bridge Template has a revolutionary granular build system:
- **Property changes**: 15-second builds
- **Widget updates**: 30-second builds  
- **Component changes**: 45-second builds
- **Feature additions**: 90-second builds
- **Module updates**: 3-minute builds

**You must ALWAYS use this system, never rebuild everything!**

### **Your Enhanced Workflow:**
1. **Read SESSION_ONBOARDING.md** - Get complete project context and git workflow
2. **Read GIT_SYNC_SYSTEM.md** - Understand commit and sync requirements  
3. **Read Work Request** - Check `/Users/eatatjoes/Desktop/ORGANIZE!/BridgeTemplate/requests.txt`
4. **Analyze Scope** - Determine minimal build scope (property→widget→component→feature→module)
5. **Execute Granular Build** - Use `./scripts/enhanced-smart-build.sh "natural language request"`
6. **Document Everything** - Comprehensive Swift DocC comments on ALL code
7. **Test Functionality** - Verify everything works including hot-swap
8. **Commit & Sync** - Follow git workflow from GIT_SYNC_SYSTEM.md

### **Key Responsibilities:**
- ✅ **Granular Building**: Use 15s-3min targeted builds only
- ✅ **Technical Execution**: Build exactly what's specified
- ✅ **Comprehensive Documentation**: Every line of code documented with Swift DocC
- ✅ **Hot-Swap Implementation**: Enable runtime component replacement
- ✅ **Professional Git Workflow**: Follow staged manual process
- ❌ **Never Full Rebuilds**: Unless explicitly required for core changes
- ❌ **Never Auto-Sync**: Manual commits only for safety

### **MANDATORY Documentation Standards:**
```swift
/// # ModuleName
/// 
/// Brief description of what this module/component does.
/// This module supports hot-swapping and independent versioning.
/// 
/// ## Overview
/// Detailed explanation of purpose, functionality, and integration points.
/// 
/// ## Topics
/// ### Main Components
/// - ``ComponentOne``
/// - ``ComponentTwo``
/// 
/// ## Version History
/// - v1.0.0: Initial implementation
/// 
/// ## Usage
/// ```swift
/// let module = ModuleName()
/// await moduleManager.loadModule(module)
/// ```
public class ModuleName: BridgeModule {
    /// Unique identifier for this module
    /// 
    /// Used by ModuleManager for hot-swapping and version tracking.
    /// Never change this value once deployed.
    public let id = "moduleName"
}
```

### **Git Workflow (CRITICAL):**
```bash
# After completing work:
git add .
git commit -m "Clear description of changes

Detailed explanation:
- What was built and why  
- Impact on other components
- Testing performed
- Documentation updated"
git push

# This triggers auto-documentation and session continuity updates
```

### **Essential Commands:**
```bash
# Check current project state
cd /Users/eatatjoes/Desktop/ORGANIZE!/BridgeTemplate

# Read work requests (your instructions)
cat requests.txt

# Execute granular builds (ALWAYS use this)
./scripts/enhanced-smart-build.sh "natural language description"

# Interactive development mode
./scripts/granular-dev.sh

# Test hot-swap functionality
./scripts/hot-swap-test.sh ModuleName 1.0.1

# Check git status
git status
git log --oneline -5
```

### **Essential References:**
- **Session Onboarding**: `docs/SESSION_ONBOARDING.md` (MUST READ FIRST)
- **Git Workflow**: `docs/GIT_SYNC_SYSTEM.md` (CRITICAL for commits)
- **Claude Code Role**: `docs/CLAUDE_CODE_ONBOARDING.md` (YOUR SPECIFIC ROLE)
- **Granular Build Guide**: `docs/CLAUDE_CODE_GRANULAR_DEV.md`
- **Architecture Patterns**: `docs/knowledge-base/COMPLETE_REFERENCE.md`

---

## 🔄 UNIVERSAL SESSION CONTINUITY

### **Every Session Starts With:**
1. **Session Onboarding**: Read `docs/SESSION_ONBOARDING.md` for complete context
2. **Git System Understanding**: Read `docs/GIT_SYNC_SYSTEM.md` for workflow
3. **Role Detection**: Understand if you're Desktop Claude or Claude Code
4. **Current State Assessment**: What was last worked on? Any incomplete tasks?
5. **Documentation Requirements**: Understand Swift DocC comment standards

### **Every Session Ends With:**
1. **Work Completion**: Finish assigned tasks completely
2. **Documentation Check**: Ensure all code has comprehensive DocC comments
3. **Git Workflow**: Follow staged manual commit process
4. **Quality Verification**: Test functionality and hot-swap capability
5. **Context Preservation**: Changes automatically update session continuity

### **Emergency Recovery:**
If session onboarding documents are unavailable:
- **Desktop Claude**: Read `docs/knowledge-base/COMPLETE_REFERENCE.md`
- **Claude Code**: Read `docs/CLAUDE_CODE_GRANULAR_DEV.md`
- **Both**: Check `PROJECT_STATUS.md` for high-level context

---

## 🎯 QUICK ACTION CHECKLIST

### **Desktop Claude Quick Start:**
- [ ] Read `docs/SESSION_ONBOARDING.md` for current context
- [ ] Read `docs/GIT_SYNC_SYSTEM.md` for workflow understanding
- [ ] Review user request and current project status
- [ ] Generate detailed specification including documentation requirements
- [ ] Write specification to `requests.txt` with git workflow instructions
- [ ] Create Claude Code prompt following established patterns

### **Claude Code Quick Start:**
- [ ] Read `docs/SESSION_ONBOARDING.md` for project context and requirements
- [ ] Read `docs/GIT_SYNC_SYSTEM.md` for git workflow and commit standards
- [ ] Check `requests.txt` for work specifications
- [ ] Analyze build scope (property→widget→component→feature→module)
- [ ] Execute using `./scripts/enhanced-smart-build.sh`
- [ ] Document everything comprehensively with Swift DocC
- [ ] Test functionality and hot-swap capability
- [ ] Follow git workflow: commit with clear message and push

### **Both Claudes Always:**
- [ ] Session onboarding documents read FIRST
- [ ] Git workflow understanding confirmed
- [ ] Role-appropriate workflow activated
- [ ] Documentation standards enforced (Swift DocC comments mandatory)
- [ ] Professional git workflow followed (staged manual, no auto-sync)
- [ ] Session continuity maintained through documentation and commits

---

## 🌉 BRIDGE TEMPLATE REVOLUTION

**What Makes This Special:**
- **Granular Intelligence**: 15s-3min builds instead of 5-10min full rebuilds
- **Hot-Swapping**: Update running apps without restart
- **Natural Language**: Describe what you want, get working code
- **Infinite Nesting**: Components within components within components
- **Perfect Documentation**: Auto-generated from comprehensive Swift DocC comments
- **Session Continuity**: Context preserved across all Claude interactions
- **Professional Git Workflow**: Staged manual commits for safety and quality

**Success Metrics:**
- ✅ 10x faster development cycles through granular builds
- ✅ Zero downtime updates via hot-swapping
- ✅ Natural language development interface
- ✅ Perfect session continuity across Claude interactions
- ✅ Professional git workflow with comprehensive documentation
- ✅ Auto-generated documentation always current with code

---

## 📞 SUPPORT & REFERENCES

### **Live Documentation:**
- **Project Repository**: https://github.com/Verborom/BridgeTemplate
- **Session Onboarding**: `/Users/eatatjoes/Desktop/ORGANIZE!/BridgeTemplate/docs/SESSION_ONBOARDING.md`
- **Git Workflow**: `/Users/eatatjoes/Desktop/ORGANIZE!/BridgeTemplate/docs/GIT_SYNC_SYSTEM.md`
- **Auto-Generated Docs**: Auto-updated with every commit

### **Local References:**
- **Project Location**: `/Users/eatatjoes/Desktop/ORGANIZE!/BridgeTemplate/`
- **Documentation**: `docs/` folder with comprehensive guides
- **Scripts**: `scripts/` folder with granular build tools

### **Integration Status:**
- ✅ **GitHub Repository**: Advanced automation and session continuity
- ✅ **Local Project**: Revolutionary granular development system
- ✅ **Documentation Pipeline**: Auto-generated from Swift DocC comments
- ✅ **Session Management**: Perfect context preservation
- ✅ **Git Workflow**: Professional staged manual process (Option 3)

---

**🚀 Ready to revolutionize development? Your role-specific workflow starts now!**

*This universal starter adapts to your role and loads current context through comprehensive session onboarding documents.*
