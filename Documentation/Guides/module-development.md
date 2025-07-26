# Module Development Guide

## Creating a New Module

1. **Create Module Structure**
   ```bash
   ./scripts/create-module.sh MyModule
   ```

2. **Implement BridgeModule Protocol**
   ```swift
   class MyModule: BridgeModule {
       let id = "com.bridge.mymodule"
       let displayName = "My Module"
       let icon = "star.fill"
       let version = ModuleVersion(major: 1, minor: 0, patch: 0)
       
       // Implementation...
   }
   ```

3. **Add Documentation**
   Every public API must have comprehensive documentation comments.

4. **Test Your Module**
   ```bash
   ./scripts/build-module.sh MyModule
   ```

5. **Hot-Swap Testing**
   ```bash
   ./scripts/hot-swap-test.sh MyModule 1.0.0
   ```

## Best Practices
- Keep modules focused and single-purpose
- Document all public APIs
- Version semantically
- Test hot-swapping scenarios
- Handle cleanup properly
