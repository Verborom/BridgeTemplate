# Architectural Rebuild Manual Testing Checklist

## Pre-Testing Setup
- [ ] Ensure on `architectural-rebuild` branch
- [ ] Verify all 5 modules exist in Modules/ directory
- [ ] Confirm UniversalTemplate system is implemented
- [ ] Check ModuleManager is updated with dynamic discovery

## Module Discovery Testing
- [ ] Launch app and verify console shows "🔍 Starting dynamic module discovery..."
- [ ] Confirm discovery finds exactly 5 modules
- [ ] Verify each module shows correct version:
  - [ ] PersonalAssistant v1.0.0
  - [ ] Projects v1.0.0
  - [ ] Documents v1.0.0
  - [ ] Settings v1.0.0
  - [ ] Terminal v1.3.0
- [ ] Check no hardcoded modules remain in discovery

## Module Loading Testing
- [ ] Verify all 5 modules appear in sidebar
- [ ] Test clicking each module loads its view
- [ ] Confirm Personal Assistant is default selection
- [ ] Verify module icons display correctly with gradients
- [ ] Check version numbers appear in UI

## UniversalTemplate Testing
- [ ] Open Personal Assistant module
- [ ] Verify sidebar shows 4 submodules:
  - [ ] Task Management
  - [ ] Calendar Integration
  - [ ] AI Chat
  - [ ] Voice Commands
- [ ] Test clicking each submodule navigates correctly
- [ ] Confirm overview shows feature cards

- [ ] Open Projects module  
- [ ] Verify sidebar shows 5 submodules:
  - [ ] Project Planning
  - [ ] Task Management
  - [ ] Team Collaboration
  - [ ] Analytics & Reporting
  - [ ] Resource Management
- [ ] Test navigation works for all submodules

- [ ] Open Documents module
- [ ] Verify 4 submodules appear
- [ ] Test navigation functionality

- [ ] Open Settings module
- [ ] Verify 4 submodules appear
- [ ] Test all navigation works

## Terminal Functionality Testing
- [ ] Open Terminal module
- [ ] Verify this is REAL Terminal (not mockup)
- [ ] Test basic shell commands work
- [ ] Confirm Claude Code integration functions
- [ ] Verify auto-permissions system works
- [ ] Test multiple terminal sessions/tabs
- [ ] Confirm PTY support and ANSI colors

## Hot-Swapping Testing
- [ ] Test hot-swap of Personal Assistant module
- [ ] Verify state preservation during swap
- [ ] Test hot-swap of Projects module
- [ ] Confirm Terminal hot-swap preserves shell sessions
- [ ] Verify UI updates correctly after hot-swap

## Navigation Integration Testing
- [ ] Test switching between all 5 modules rapidly
- [ ] Verify no crashes or memory leaks
- [ ] Confirm smooth transitions
- [ ] Test back/forward navigation if applicable
- [ ] Verify keyboard shortcuts work (if implemented)

## Performance Testing
- [ ] Measure app launch time (should be under 3 seconds)
- [ ] Test module switching performance (should be instant)
- [ ] Monitor memory usage with all modules loaded
- [ ] Verify no memory leaks during hot-swapping
- [ ] Test app remains responsive under load

## Error Handling Testing
- [ ] Test behavior with corrupted version.json
- [ ] Verify graceful handling of missing modules
- [ ] Test dependency resolution errors
- [ ] Confirm error messages are helpful
- [ ] Verify app doesn't crash on module errors

## Documentation Validation
- [ ] Verify all Swift code has DocC comments
- [ ] Check documentation generates correctly
- [ ] Confirm API documentation is comprehensive
- [ ] Verify module guides are up-to-date
- [ ] Test documentation links work

## Final Integration Validation
- [ ] All 5 modules load successfully ✅
- [ ] Dynamic discovery works without hardcoding ✅  
- [ ] UniversalTemplate generates proper hierarchies ✅
- [ ] Terminal real functionality preserved ✅
- [ ] Hot-swapping works across all modules ✅
- [ ] Performance meets expectations ✅
- [ ] No regressions from original system ✅