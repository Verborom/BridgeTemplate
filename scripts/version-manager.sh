#!/bin/bash

# Bridge Template - Version Management Script
# Handles version bumping, tagging, and cleanup

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get project root
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

# Function to read current version
get_current_version() {
    if [ -f VERSION ]; then
        cat VERSION
    else
        echo "1.0.0"
    fi
}

# Function to bump version
bump_version() {
    local current_version=$(get_current_version)
    local bump_type="$1"
    
    # Parse version components
    IFS='.' read -r major minor patch <<< "$current_version"
    
    case $bump_type in
        major)
            major=$((major + 1))
            minor=0
            patch=0
            ;;
        minor)
            minor=$((minor + 1))
            patch=0
            ;;
        patch)
            patch=$((patch + 1))
            ;;
        *)
            echo -e "${RED}Invalid bump type: $bump_type${NC}"
            echo "Use: major, minor, or patch"
            exit 1
            ;;
    esac
    
    local new_version="$major.$minor.$patch"
    echo "$new_version"
}

# Function to update version files
update_version_files() {
    local new_version="$1"
    local old_version=$(get_current_version)
    
    echo -e "${YELLOW}Updating version from $old_version to $new_version${NC}"
    
    # Update VERSION file
    echo "$new_version" > VERSION
    
    # Update CHANGELOG
    local date=$(date +%Y-%m-%d)
    local temp_file=$(mktemp)
    
    # Add new version section to changelog
    {
        echo "# Changelog"
        echo ""
        echo "All notable changes to Bridge Template will be documented in this file."
        echo ""
        echo "The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),"
        echo "and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html)."
        echo ""
        echo "## [$new_version] - $date"
        echo ""
        echo "### Added"
        echo "- "
        echo ""
        echo "### Changed"
        echo "- "
        echo ""
        echo "### Fixed"
        echo "- "
        echo ""
        # Append rest of changelog
        tail -n +7 CHANGELOG.md
    } > "$temp_file"
    
    mv "$temp_file" CHANGELOG.md
    
    echo -e "${GREEN}✓ Version files updated${NC}"
}

# Function to create git tag
create_git_tag() {
    local version="$1"
    local message="$2"
    
    if [ -z "$message" ]; then
        message="Release version $version"
    fi
    
    echo -e "${YELLOW}Creating git tag v$version${NC}"
    
    # Check if we're in a git repo
    if [ ! -d .git ]; then
        echo -e "${YELLOW}Warning: Not in a git repository${NC}"
        return
    fi
    
    # Create tag
    git tag -a "v$version" -m "$message"
    echo -e "${GREEN}✓ Git tag created${NC}"
}

# Function to cleanup old versions
cleanup_old_versions() {
    local keep_count=3  # Number of versions to keep
    
    echo -e "${YELLOW}Cleaning up old versions (keeping last $keep_count)${NC}"
    
    # Clean macOS builds
    if [ -d "builds/macos" ]; then
        cd "$PROJECT_ROOT/builds/macos"
        # Get all version directories sorted by modification time
        local versions=($(ls -dt v*/ 2>/dev/null | head -n -$keep_count))
        for version in "${versions[@]}"; do
            echo -e "${YELLOW}Removing macOS $version${NC}"
            rm -rf "$version"
        done
    fi
    
    # Clean iOS builds
    if [ -d "builds/ios" ]; then
        cd "$PROJECT_ROOT/builds/ios"
        # Get all version directories sorted by modification time
        local versions=($(ls -dt v*/ 2>/dev/null | head -n -$keep_count))
        for version in "${versions[@]}"; do
            echo -e "${YELLOW}Removing iOS $version${NC}"
            rm -rf "$version"
        done
    fi
    
    cd "$PROJECT_ROOT"
    echo -e "${GREEN}✓ Cleanup completed${NC}"
}

# Function to show version info
show_version_info() {
    local current_version=$(get_current_version)
    
    echo -e "${BLUE}Bridge Template Version Information${NC}"
    echo -e "${BLUE}===================================${NC}"
    echo "Current version: $current_version"
    echo ""
    
    # Show recent versions from git tags
    if [ -d .git ]; then
        echo "Recent versions:"
        git tag -l "v*" | sort -V | tail -5 | while read tag; do
            echo "  $tag"
        done
    fi
    
    echo ""
    echo "Build versions:"
    
    # macOS versions
    if [ -d "builds/macos" ]; then
        echo "  macOS:"
        ls -d builds/macos/v*/ 2>/dev/null | sort -V | tail -3 | while read dir; do
            echo "    - $(basename $dir)"
        done
    fi
    
    # iOS versions
    if [ -d "builds/ios" ]; then
        echo "  iOS:"
        ls -d builds/ios/v*/ 2>/dev/null | sort -V | tail -3 | while read dir; do
            echo "    - $(basename $dir)"
        done
    fi
}

# Function to verify GitHub backup
verify_github_backup() {
    local version="$1"
    
    echo -e "${YELLOW}Verifying GitHub backup for v$version${NC}"
    
    # Check if git tag exists on remote
    if git ls-remote --tags origin | grep -q "refs/tags/v$version"; then
        echo -e "${GREEN}✓ Version v$version backed up to GitHub${NC}"
        return 0
    else
        echo -e "${YELLOW}⚠ Version v$version not found on GitHub${NC}"
        return 1
    fi
}

# Main command handling
case "${1:-help}" in
    bump)
        if [ -z "$2" ]; then
            echo -e "${RED}Error: Specify bump type (major, minor, patch)${NC}"
            exit 1
        fi
        
        new_version=$(bump_version "$2")
        update_version_files "$new_version"
        
        # Optionally create git tag
        if [ "$3" != "--no-tag" ]; then
            create_git_tag "$new_version" "$4"
        fi
        
        echo -e "\n${GREEN}Version bumped to $new_version${NC}"
        ;;
        
    tag)
        version=$(get_current_version)
        create_git_tag "$version" "$2"
        ;;
        
    cleanup)
        cleanup_old_versions
        ;;
        
    info)
        show_version_info
        ;;
        
    verify)
        if [ -z "$2" ]; then
            version=$(get_current_version)
        else
            version="$2"
        fi
        verify_github_backup "$version"
        ;;
        
    help|--help|-h)
        echo "Bridge Template Version Manager"
        echo ""
        echo "Usage: $0 <command> [options]"
        echo ""
        echo "Commands:"
        echo "  bump <type> [--no-tag] [message]  Bump version (major/minor/patch)"
        echo "  tag [message]                      Create git tag for current version"
        echo "  cleanup                            Remove old version builds"
        echo "  info                               Show version information"
        echo "  verify [version]                   Verify GitHub backup"
        echo "  help                               Show this help message"
        echo ""
        echo "Examples:"
        echo "  $0 bump patch                      # Bump patch version and create tag"
        echo "  $0 bump minor --no-tag             # Bump minor version without tag"
        echo "  $0 bump major \"Major release\"      # Bump major with custom message"
        echo "  $0 cleanup                         # Clean old builds"
        ;;
        
    *)
        echo -e "${RED}Unknown command: $1${NC}"
        echo "Use '$0 help' for usage information"
        exit 1
        ;;
esac