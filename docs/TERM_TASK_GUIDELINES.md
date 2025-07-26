# Term Task Guidelines - Modular Development Strategy

## Core Principle: Always Working Software

**Every task given to Term (Claude Code) must be completable and result in working software.**

## Task Sizing Guidelines

### ✅ Perfect Term Task Size
- **Single focused objective** - One clear goal
- **1-2 files maximum** to create or modify
- **10-30 minutes completion time**
- **Immediately testable** - User can see/test result
- **Clear visual outcome** - Something user can observe working
- **Independent of other incomplete features**

### ❌ Too Big for Term
- Multiple interconnected systems
- Complex architecture setup all at once
- Abstract or unclear outcomes
- Dependencies on unbuilt components
- More than 2-3 files to coordinate

## Nested Module Architecture

### Module Hierarchy Support
```
MainModule
├── CoreSubmodule
├── UISubmodule  
├── DataSubmodule
└── LogicSubmodule
```

**Benefits:**
- Each submodule can be built independently
- Always have working components
- Easy to test individual pieces
- Can develop features in parallel
- Never break existing functionality

## Task Examples

### ✅ Good Term Tasks
- "Add gradient background to sidebar"
- "Create draggable project tile component" 
- "Add theme toggle button that works"
- "Create basic chat input field"
- "Add working file picker to settings"

### ❌ Bad Term Tasks  
- "Build complete project management system"
- "Implement full modular architecture"
- "Create entire chat system with AI integration"
- "Build dashboard with all metrics and charts"

## Development Workflow

### Step-by-Step Module Building
1. **Foundation** - Basic structure that works
2. **Core Features** - Essential functionality, one piece at a time
3. **UI Polish** - Visual improvements, component by component  
4. **Advanced Features** - Complex functionality, broken into small tasks
5. **Integration** - Connect completed modules

### Example: Projects Module Development
1. ✅ Basic project list view (works alone)
2. ✅ Add project creation button (works with #1)
3. ✅ Add project tile component (works with #1,#2)
4. ✅ Add drag gesture to tiles (works with previous)
5. ✅ Add data persistence (works with all previous)
6. ✅ Add priority reordering (works with all previous)

## Writing Term Specifications

### Always Include:
- **Single clear objective**
- **Exact file locations** to modify
- **Simple success criteria**
- **What NOT to do** (scope limitations)
- **Immediate testing steps**

### Template for Term Tasks:
```
TASK: [One clear, simple objective]
MODIFY: [Specific file or create specific new file]
SUCCESS: [User can see/test this specific result]
DON'T: [Scope limitations to keep task focused]
```

## Quality Assurance

### Every Completed Task Should:
- ✅ Build without errors
- ✅ Launch and function correctly
- ✅ Show clear visual progress
- ✅ Not break existing functionality
- ✅ Be testable by user immediately

### Red Flags - Stop and Reassess:
- ❌ Term works long time but produces nothing
- ❌ User can't test/see the result
- ❌ Task depends on unbuilt components
- ❌ Specification is longer than implementation would be

## Integration Strategy

### Building Complex Features:
1. **Start with simplest working version**
2. **Add one capability at a time**
3. **Test each addition independently**
4. **Keep each step working**
5. **Never break existing functionality**

### Module Communication:
- Use well-defined interfaces between modules
- Each module should work independently when possible
- Clear data contracts between modules
- Minimal dependencies between modules

---

**Remember: The goal is ALWAYS working software, built incrementally through small, successful tasks.**