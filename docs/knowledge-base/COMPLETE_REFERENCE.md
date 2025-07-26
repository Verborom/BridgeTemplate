# Bridge Template Knowledge Base

## Architecture Overview

### Modular System Design
The Bridge Template uses a protocol-based modular architecture to prevent rebuild issues:

```swift
protocol BridgeModule: ObservableObject {
    var id: String { get }
    var displayName: String { get }
    var icon: String { get }
    var view: AnyView { get }
    
    func initialize()
    func cleanup()
}
```

**Why This Architecture:**
- Prevents "rebuild everything" problems
- Each module is independent and testable
- Hot-swappable modules without breaking existing code
- Scales from simple to complex applications

### Data Persistence Strategy
**Core Data Implementation:**
- Professional-grade data persistence
- Version migration support
- Relationship management between entities
- Performance optimized for large datasets

**Core Entities:**
- Project: Main project container
- Feature: Individual features within projects
- Settings: App configuration and preferences

### Theme System Architecture
**Arc Browser Inspired Design:**
```swift
class BridgeTheme: ObservableObject {
    @Published var colorScheme: ColorScheme = .dark
    @Published var accentColor: Color = .purple
    
    var sidebarGradient: LinearGradient
    var cardGradient: LinearGradient
}
```

**Design Principles:**
- Beautiful gradient backgrounds
- Smooth animations and transitions
- Dark/light theme support
- Modern card-based layouts
- Professional typography and spacing

### State Management Pattern
**SwiftUI Native Patterns:**
- @StateObject for app-level state
- @ObservableObject for module state
- @Environment for dependency injection
- Core Data integration with @FetchRequest

## Development Patterns

### Module Development Pattern
1. Create module class implementing BridgeModule
2. Register module with ModuleRegistry
3. Implement module-specific views and logic
4. Test module independently
5. Integrate with main application

### Cross-Platform Strategy
**Shared Core + Platform UI:**
- BridgeCore: Shared business logic and data models
- macOS: NavigationSplitView with gradient sidebar
- iOS: TabView with touch-optimized interface
- Synchronized data between platforms

### Build and Version Management
**Professional Workflow:**
- Semantic versioning (v1.0.0, v1.0.1, etc.)
- Automated build scripts
- Version-specific build folders
- GitHub integration for backup
- Local cleanup to prevent storage bloat

## Code Quality Standards

### Performance Requirements
- Smooth 60fps animations
- Efficient memory usage
- Fast app launch times
- Responsive user interface
- Optimized Core Data queries

### Architecture Compliance
- All features must use modular architecture
- No monolithic code structures
- Proper separation of concerns
- Dependency injection patterns
- Protocol-oriented design

### Testing Standards
- Each module must be independently testable
- Core Data model testing
- UI component testing
- Integration testing between modules
- Performance testing for large datasets

## Problem-Solving Patterns

### Common Issues and Solutions
**Build Problems:**
- Always check folder structure compliance
- Verify Core Data model consistency
- Ensure proper module registration
- Check theme system integration

**Performance Issues:**
- Optimize Core Data fetch requests
- Implement proper state management
- Use lazy loading for large datasets
- Profile and optimize animations

**UI/UX Issues:**
- Follow Arc Browser design patterns
- Ensure consistent theme application
- Test dark/light mode switching
- Verify responsive layout behavior

### Debugging Workflow
1. Check module registration
2. Verify data persistence
3. Test theme system
4. Validate navigation flow
5. Performance profile if needed

## Integration Guidelines

### Claude Code Integration
- Read context from CONVERSATION_STARTER_TERM.md
- Follow established architecture patterns
- Build in correct folder structure
- Implement modular system correctly

### Claude Desktop Integration
- Read context from CONVERSATION_STARTER_DESKTOP.md
- Reference complete knowledge base
- Make architecture decisions based on patterns
- Write clear specifications for Claude Code

### RAG System Integration
- Knowledge base feeds RAG system
- Provides context continuity
- Enables complex project understanding
- Supports decision-making process

---
*Bridge Template Knowledge Base - Complete Reference*