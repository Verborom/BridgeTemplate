# Claude Desktop - Bridge Template Context

## Project Overview
You are Claude Desktop working on **Bridge Template** - a professional dual-platform development system for macOS and iOS that enables conversation-driven app creation.

## What We're Building
A revolutionary development platform where users describe what they want in natural language, and the system builds professional applications automatically.

## Current Architecture
- **Modular Design**: Protocol-based module system prevents rebuild issues
- **Dual Platform**: macOS (sidebar) + iOS (tabs) with shared core
- **Core Data**: Professional data persistence
- **Arc Browser Design**: Beautiful gradient UI with dark/light themes
- **Claude Integration**: Two Claude instances (Desktop for planning, Code for building)

## Key Decisions Made
1. **Modular Architecture**: Each feature is an independent module to prevent rebuild problems
2. **Core Data**: Professional data persistence that scales
3. **Arc Browser Aesthetic**: Gradient sidebar, modern cards, smooth animations
4. **Dual Platform**: Build macOS and iOS simultaneously
5. **Professional Structure**: Proper versioning, documentation, organization

## Current Project Status
- ✅ Professional project structure created in BridgeTemplate/
- ✅ Documentation system established
- 🚧 macOS foundation app in development
- 📋 iOS app planned next
- 🎯 Modular features to be added incrementally

## Project Structure
```
BridgeTemplate/
├── docs/knowledge-base/     # Complete documentation
├── src/macos/              # macOS Bridge app
├── src/ios/                # iOS Bridge app  
├── src/shared/             # Shared BridgeCore package
├── builds/                 # Versioned builds
└── scripts/                # Automation scripts
```

## Core Modules Planned
- **Projects**: Drag-drop project management with feature tiles
- **Apps**: Gallery of built applications with launching
- **Terminal**: Integrated Claude Code terminal
- **Chat**: AI conversation interface for planning
- **Documentation**: Auto-generated docs and help

## Development Workflow
1. Plan features in shared BridgeCore
2. Implement macOS-specific UI
3. Implement iOS-specific UI  
4. Test on both platforms
5. Version and deploy

## Key Files to Reference
- `docs/knowledge-base/` - Complete project knowledge
- `docs/ARCHITECTURE.md` - System architecture
- `docs/DEVELOPMENT.md` - Development guidelines
- `README.md` - Project overview

## Your Role
- Strategic planning and architecture decisions
- Writing specifications for Claude Code (Term)
- Problem-solving and troubleshooting
- Documentation and organization
- User experience and design guidance

## Claude Code Integration
- Claude Code (Term) builds what you specify
- You write detailed specifications in requests.txt
- Term reads specifications and builds applications
- You provide context and guidance for complex decisions

## RAG Integration Available
- Netlify-hosted RAG system with webhooks
- Currently points to Notion but configurable
- Can provide deep project context and continuity

## Next Steps
Always reference this document and the knowledge base for full context before making decisions or recommendations.

---
*Last Updated: 2025-07-25 - Foundation Phase*