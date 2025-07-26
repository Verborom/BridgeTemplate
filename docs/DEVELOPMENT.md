# Development Guide

## Prerequisites

### Required Tools
- macOS 13.0 or later
- Xcode 15.0 or later
- Swift 5.9 or later
- Git 2.0 or later

### Optional Tools
- [SwiftLint](https://github.com/realm/SwiftLint) for code style
- [Sourcery](https://github.com/krzysztofzablocki/Sourcery) for code generation
- [fastlane](https://fastlane.tools) for automation

## Getting Started

### 1. Clone the Repository
```bash
git clone https://github.com/yourusername/BridgeTemplate.git
cd BridgeTemplate
```

### 2. Install Dependencies
```bash
# Install SwiftLint (optional)
brew install swiftlint

# Install pre-commit hooks
./scripts/setup-hooks.sh
```

### 3. Open the Project
```bash
# For macOS development
open src/macos/BridgeMac.xcodeproj

# For iOS development
open src/ios/BridgeiOS.xcodeproj
```

## Project Structure

### Source Organization
```
src/
├── shared/                 # Shared code (BridgeCore package)
│   ├── Sources/
│   │   └── BridgeCore/    # Core functionality
│   └── Tests/
│       └── BridgeCoreTests/
├── macos/                 # macOS-specific code
│   └── BridgeMac/
└── ios/                   # iOS-specific code
    └── BridgeiOS/
```

### Key Components

#### BridgeCore (Shared)
- `Models/` - Data models and entities
- `Services/` - Business logic and services
- `Extensions/` - Swift extensions
- `Utilities/` - Helper functions and utilities

#### Platform Apps
- `Views/` - UI components
- `ViewModels/` - View models (MVVM)
- `Resources/` - Assets and resources
- `App.swift` - App entry point

## Development Workflow

### 1. Feature Development

#### Create a Feature Branch
```bash
git checkout -b feature/your-feature-name
```

#### Implement Your Feature
1. Start with shared code in `BridgeCore`
2. Add platform-specific UI
3. Write tests alongside implementation
4. Update documentation

### 2. Building

#### Build All Platforms
```bash
./scripts/build.sh
```

#### Build Specific Platform
```bash
./scripts/build.sh macos
./scripts/build.sh ios
```

#### Build Options
```bash
# Debug build
./scripts/build.sh --debug

# Release build
./scripts/build.sh --release

# Clean build
./scripts/build.sh --clean
```

### 3. Testing

#### Run All Tests
```bash
./scripts/test.sh
```

#### Run Specific Tests
```bash
# Unit tests only
./scripts/test.sh unit

# UI tests only
./scripts/test.sh ui

# Platform-specific
./scripts/test.sh macos
./scripts/test.sh ios
```

### 4. Code Style

#### SwiftLint
The project uses SwiftLint for consistent code style:
```bash
# Run linter
swiftlint

# Auto-fix issues
swiftlint --fix
```

#### Code Formatting
- Use 4 spaces for indentation
- Follow Swift API Design Guidelines
- Keep line length under 120 characters

## Version Management

### Semantic Versioning
We follow [Semantic Versioning](https://semver.org/):
- MAJOR.MINOR.PATCH
- Example: 1.2.3

### Version Bumping
```bash
# Bump patch version (1.0.0 -> 1.0.1)
./scripts/version-manager.sh bump patch

# Bump minor version (1.0.0 -> 1.1.0)
./scripts/version-manager.sh bump minor

# Bump major version (1.0.0 -> 2.0.0)
./scripts/version-manager.sh bump major
```

### Creating a Release
```bash
# Create a new release
./scripts/release.sh

# This will:
# 1. Run tests
# 2. Build release binaries
# 3. Create version tag
# 4. Update changelog
# 5. Create GitHub release
```

## Debugging

### Xcode Debugging
1. Set breakpoints in code
2. Use Debug navigator
3. Inspect variables
4. Use LLDB commands

### Logging
```swift
// Use os.log for logging
import os

let logger = Logger(subsystem: "com.bridge.template", category: "MyCategory")
logger.debug("Debug message")
logger.info("Info message")
logger.error("Error message")
```

### Common Issues

#### Build Failures
```bash
# Clean build folder
./scripts/clean.sh

# Reset package cache
rm -rf .build
swift package reset
```

#### Signing Issues
1. Check team settings in Xcode
2. Verify provisioning profiles
3. Update certificates if needed

## Contributing

### Pull Request Process
1. Create feature branch
2. Make changes
3. Write/update tests
4. Update documentation
5. Submit pull request
6. Address review feedback
7. Merge after approval

### Commit Messages
Follow conventional commits:
```
feat: add new feature
fix: fix bug
docs: update documentation
style: format code
refactor: refactor code
test: add tests
chore: update dependencies
```

### Code Review Checklist
- [ ] Tests pass
- [ ] Documentation updated
- [ ] No SwiftLint warnings
- [ ] Performance considered
- [ ] Security reviewed
- [ ] Accessibility checked

## Performance

### Profiling
Use Instruments for performance profiling:
1. Time Profiler
2. Allocations
3. Leaks
4. Energy Log

### Optimization Tips
- Use lazy loading
- Minimize view updates
- Cache expensive operations
- Profile before optimizing

## Deployment

### Local Testing
```bash
# Install locally
./scripts/install-local.sh
```

### Beta Distribution
```bash
# Create beta build
./scripts/beta-release.sh
```

### App Store Release
```bash
# Prepare for App Store
./scripts/app-store-release.sh
```

## Resources

### Documentation
- [Swift Documentation](https://swift.org/documentation/)
- [Apple Developer Documentation](https://developer.apple.com/documentation/)
- [SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)

### Community
- Project Issues: GitHub Issues
- Discussions: GitHub Discussions
- Chat: Slack/Discord (if applicable)

---

Happy coding! 🚀