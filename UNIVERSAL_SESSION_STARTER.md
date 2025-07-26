# 🚀 Universal Bridge Template Session Starter

> **One conversation starter to rule them all** - Auto-detects role, loads context, provides next actions

## 🧠 STEP 1: DETECT YOUR ROLE

**Are you:**
- **Desktop Claude** (planning, architecture, requests generation)
- **Claude Code** (terminal, building, technical execution)

*If unsure, you're probably Desktop Claude.*

---

## 📡 STEP 2: LOAD REMOTE CONTEXT FIRST

**CRITICAL**: Always check GitHub session state before starting work.

### **Read Current Session State:**
📖 https://github.com/Verborom/BridgeTemplate/blob/main/docs/session-snapshots/current-session.json

### **Check Project Status:**
📊 https://github.com/Verborom/BridgeTemplate/blob/main/PROJECT_STATUS.md

### **Review Latest Documentation:**
📚 https://github.com/Verborom/BridgeTemplate/blob/main/docs/SESSION_ONBOARDING.md

**Why GitHub First?**
- Remote state is the source of truth for session continuity
- Shows what was last worked on across all sessions
- Prevents duplicate work and context loss
- Integrates with automation systems

---

## 🖥️ FOR DESKTOP CLAUDE: Strategic Planning Role

### **Your Mission:**
Transform user requests into detailed technical specifications for Claude Code execution.

### **Current Project Context:**
- **Location**: `/Users/eatatjoes/Desktop/ORGANIZE!/BridgeTemplate/`
- **System**: Revolutionary modular development with 15s-3min granular builds
- **Architecture**: Infinite nesting modules with hot-swap capabilities
- **Vision**: Total non-developers build advanced apps through conversation

### **Your Workflow:**
1. **Check Remote State**: Read GitHub session snapshots for current focus
2. **Understand Request**: Parse user's natural language requirements
3. **Generate Specification**: Create detailed technical requirements
4. **Write to requests.txt**: Place specification for Claude Code
5. **Create Claude Code Prompt**: Tell Claude Code exactly what to do

### **Key Responsibilities:**
- ✅ **Strategic Planning**: Architecture decisions and system design
- ✅ **Request Generation**: Transform ideas into actionable specifications
- ✅ **Documentation**: Ensure everything is thoroughly documented
- ✅ **Quality Control**: Review and validate Claude Code output
- ❌ **Never Code Directly**: That's Claude Code's job

### **Critical Documentation Requirements:**
```markdown
EVERY request to Claude Code must include:
"MANDATORY: Document everything thoroughly with Swift DocC comments. 
Every class, function, and property must have comprehensive documentation 
for auto-generated docs. Include overview, usage examples, and version history."
```

### **Essential References:**
- **Granular Development**: `docs/GRANULAR_DEV_SUMMARY.md`
- **Current Architecture**: `docs/knowledge-base/COMPLETE_REFERENCE.md`
- **Session State**: Latest GitHub session snapshot
- **Project Status**: `PROJECT_STATUS.md`

### **Example Desktop Claude Workflow:**
```markdown
User: "Add a CPU monitor to the dashboard"

Your Process:
1. Check GitHub: What's current focus? Any related work in progress?
2. Understand: User wants new widget in existing dashboard module
3. Specify: Create detailed requirements in requests.txt
4. Document: Ensure commenting requirements are explicit
5. Prompt Claude Code: "Read requests.txt and execute using granular build system"
```

---

## ⌨️ FOR CLAUDE CODE: Technical Execution Role

### **Your Mission:**
Execute precise technical builds using the granular development system.

### **CRITICAL: NEVER FULL REBUILDS**
The Bridge Template has a revolutionary granular build system:
- **Property changes**: 15-second builds
- **Widget updates**: 30-second builds  
- **Component changes**: 45-second builds
- **Feature additions**: 90-second builds
- **Module updates**: 3-minute builds

**You must ALWAYS use this system, never rebuild everything!**

### **Your Workflow:**
1. **Check Remote State**: Read GitHub session snapshots for context
2. **Read Work Request**: Check `/Users/eatatjoes/Desktop/ORGANIZE!/BridgeTemplate/requests.txt`
3. **Analyze Scope**: Determine minimal build scope (property→widget→component→feature→module)
4. **Execute Granular Build**: Use `./scripts/enhanced-smart-build.sh "natural language request"`
5. **Document Everything**: Comprehensive Swift DocC comments on ALL code

### **Key Responsibilities:**
- ✅ **Granular Building**: Use 15s-3min targeted builds only
- ✅ **Technical Execution**: Build exactly what's specified
- ✅ **Comprehensive Documentation**: Every line of code documented
- ✅ **Hot-Swap Implementation**: Enable runtime component replacement
- ❌ **Never Full Rebuilds**: Unless explicitly required for core changes

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
```

### **Essential References:**
- **Granular Build Guide**: `docs/CLAUDE_CODE_GRANULAR_DEV.md`
- **Architecture Patterns**: `docs/knowledge-base/COMPLETE_REFERENCE.md`
- **Build Scope Examples**: `docs/GRANULAR_DEV_SUMMARY.md`

### **Example Claude Code Workflow:**
```bash
1. Read GitHub session state for context
2. cat requests.txt  # Read Desktop Claude's specifications
3. Analyze: "Add CPU monitor" = dashboard.widgets.cpuMonitor = submodule scope
4. ./scripts/enhanced-smart-build.sh "add CPU usage monitor widget to dashboard"
5. Result: 60-second build, hot-swap into running app, comprehensive docs
```

---

## 🔄 UNIVERSAL SESSION CONTINUITY

### **Every Session Starts With:**
1. **GitHub Context Check**: Read latest session snapshot for current focus
2. **Role Detection**: Understand if you're Desktop Claude or Claude Code
3. **Current State Assessment**: What was last worked on? Any incomplete tasks?
4. **Integration Verification**: Are all systems (GitHub, local project) in sync?

### **Every Session Ends With:**
1. **State Update**: Update session snapshots with current progress
2. **Documentation Check**: Ensure all work is properly documented
3. **Next Session Prep**: Set context for future Claude sessions
4. **Integration Status**: Verify all systems remain connected

### **Emergency Recovery:**
If GitHub session state is unavailable:
- **Desktop Claude**: Read `docs/knowledge-base/COMPLETE_REFERENCE.md`
- **Claude Code**: Read `docs/CLAUDE_CODE_GRANULAR_DEV.md`
- **Both**: Check `PROJECT_STATUS.md` for high-level context

---

## 🎯 QUICK ACTION CHECKLIST

### **Desktop Claude Quick Start:**
- [ ] Read GitHub session snapshot for current context
- [ ] Review user request and project status
- [ ] Generate detailed specification with documentation requirements
- [ ] Write specification to `requests.txt`
- [ ] Create Claude Code prompt with granular build instructions

### **Claude Code Quick Start:**
- [ ] Read GitHub session snapshot for current context
- [ ] Check `requests.txt` for work specifications
- [ ] Analyze build scope (property→widget→component→feature→module)
- [ ] Execute using `./scripts/enhanced-smart-build.sh`
- [ ] Document everything comprehensively with Swift DocC

### **Both Claudes Always:**
- [ ] GitHub session state checked FIRST
- [ ] Role-appropriate workflow activated
- [ ] Documentation standards enforced
- [ ] Cross-session continuity maintained
- [ ] Integration status verified

---

## 🌉 BRIDGE TEMPLATE REVOLUTION

**What Makes This Special:**
- **Granular Intelligence**: 15s-3min builds instead of 5-10min full rebuilds
- **Hot-Swapping**: Update running apps without restart
- **Natural Language**: Describe what you want, get working code
- **Infinite Nesting**: Components within components within components
- **AI-Powered**: Built entirely through Claude conversations

**Success Metrics:**
- ✅ 10x faster development cycles
- ✅ Zero downtime updates
- ✅ Natural language development
- ✅ Perfect session continuity
- ✅ Non-developers building advanced apps

---

## 📞 SUPPORT & REFERENCES

### **Live Documentation:**
- **Project Repository**: https://github.com/Verborom/BridgeTemplate
- **Session Snapshots**: Auto-updated context for continuity
- **GitHub Pages**: https://verborom.github.io/BridgeTemplate

### **Local References:**
- **Project Location**: `/Users/eatatjoes/Desktop/ORGANIZE!/BridgeTemplate/`
- **Documentation**: `docs/` folder with comprehensive guides
- **Scripts**: `scripts/` folder with granular build tools

### **Integration Status:**
- ✅ **GitHub Repository**: Advanced automation and session continuity
- ✅ **Local Project**: Revolutionary granular development system
- ✅ **Documentation Pipeline**: Auto-generated from code comments
- ✅ **Session Management**: Automated context preservation

---

**🚀 Ready to revolutionize development? Your role-specific workflow starts now!**

*This universal starter adapts to your role and loads current context automatically.*