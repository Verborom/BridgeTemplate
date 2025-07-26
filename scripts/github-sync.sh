#!/bin/bash

# Bridge Template - GitHub Synchronization Script
# Handles git operations and GitHub integration

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

# Configuration
GITHUB_REPO=""  # Set this to your GitHub repo URL
BRANCH="main"

# Function to check git status
check_git_status() {
    if [ ! -d .git ]; then
        echo -e "${RED}Error: Not a git repository${NC}"
        echo "Run 'git init' first"
        exit 1
    fi
    
    # Check for uncommitted changes
    if ! git diff-index --quiet HEAD --; then
        echo -e "${YELLOW}Warning: You have uncommitted changes${NC}"
        git status --short
        echo ""
        read -p "Continue anyway? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

# Function to sync with GitHub
sync_to_github() {
    echo -e "${BLUE}Syncing with GitHub...${NC}"
    
    # Fetch latest
    echo -e "${YELLOW}Fetching from remote...${NC}"
    git fetch origin
    
    # Pull latest changes
    echo -e "${YELLOW}Pulling latest changes...${NC}"
    git pull origin "$BRANCH" --rebase
    
    # Push changes
    echo -e "${YELLOW}Pushing to GitHub...${NC}"
    git push origin "$BRANCH"
    
    # Push tags
    echo -e "${YELLOW}Pushing tags...${NC}"
    git push origin --tags
    
    echo -e "${GREEN}✓ GitHub sync completed${NC}"
}

# Function to create release
create_release() {
    local version="$1"
    local notes="$2"
    
    if [ -z "$version" ]; then
        version=$(cat VERSION)
    fi
    
    echo -e "${BLUE}Creating GitHub release v$version${NC}"
    
    # Check if gh CLI is installed
    if ! command -v gh &> /dev/null; then
        echo -e "${YELLOW}GitHub CLI (gh) not installed${NC}"
        echo "Install with: brew install gh"
        echo "Creating tag only..."
        
        git tag -a "v$version" -m "Release v$version"
        git push origin "v$version"
        return
    fi
    
    # Create release notes file
    local release_notes=$(mktemp)
    if [ -z "$notes" ]; then
        # Extract from CHANGELOG
        echo "# Release v$version" > "$release_notes"
        echo "" >> "$release_notes"
        
        # Extract the section for this version from CHANGELOG
        awk "/## \[$version\]/{flag=1; next} /## \[/{flag=0} flag" CHANGELOG.md >> "$release_notes"
    else
        echo "$notes" > "$release_notes"
    fi
    
    # Create GitHub release
    gh release create "v$version" \
        --title "Bridge Template v$version" \
        --notes-file "$release_notes" \
        --target "$BRANCH"
    
    rm -f "$release_notes"
    echo -e "${GREEN}✓ GitHub release created${NC}"
}

# Function to setup GitHub repository
setup_github() {
    echo -e "${BLUE}Setting up GitHub repository${NC}"
    
    # Check if remote exists
    if git remote get-url origin &> /dev/null; then
        GITHUB_REPO=$(git remote get-url origin)
        echo -e "${GREEN}✓ Remote already configured: $GITHUB_REPO${NC}"
    else
        echo "Enter your GitHub repository URL:"
        echo "Example: https://github.com/username/BridgeTemplate.git"
        read -p "URL: " repo_url
        
        if [ -z "$repo_url" ]; then
            echo -e "${RED}Error: Repository URL required${NC}"
            exit 1
        fi
        
        git remote add origin "$repo_url"
        GITHUB_REPO="$repo_url"
        echo -e "${GREEN}✓ Remote added${NC}"
    fi
    
    # Update script with repo URL
    sed -i '' "s|GITHUB_REPO=\"\"|GITHUB_REPO=\"$GITHUB_REPO\"|" "$0"
}

# Function to backup to GitHub
backup_builds() {
    echo -e "${BLUE}Backing up builds to GitHub...${NC}"
    
    # Create builds branch if it doesn't exist
    if ! git show-ref --verify --quiet refs/heads/builds; then
        git checkout -b builds
    else
        git checkout builds
    fi
    
    # Add build files (only metadata, not binaries)
    find builds -name "*.txt" -o -name "*.json" -o -name "*.plist" | xargs git add
    
    # Commit if there are changes
    if ! git diff-index --quiet HEAD --; then
        git commit -m "Backup builds metadata $(date +%Y-%m-%d)"
        git push origin builds
    fi
    
    # Switch back to main branch
    git checkout "$BRANCH"
    
    echo -e "${GREEN}✓ Builds backed up${NC}"
}

# Function to initialize git repository
init_git() {
    echo -e "${BLUE}Initializing git repository${NC}"
    
    if [ -d .git ]; then
        echo -e "${YELLOW}Git repository already initialized${NC}"
        return
    fi
    
    # Initialize git
    git init
    
    # Create initial commit
    git add .
    git commit -m "Initial commit - Bridge Template project structure"
    
    # Rename branch to main
    git branch -M main
    
    echo -e "${GREEN}✓ Git repository initialized${NC}"
}

# Main command handling
case "${1:-help}" in
    init)
        init_git
        setup_github
        ;;
        
    sync)
        check_git_status
        sync_to_github
        ;;
        
    release)
        check_git_status
        create_release "$2" "$3"
        ;;
        
    backup)
        check_git_status
        backup_builds
        ;;
        
    setup)
        setup_github
        ;;
        
    status)
        echo -e "${BLUE}Repository Status${NC}"
        echo -e "${BLUE}=================${NC}"
        
        if [ -d .git ]; then
            echo "Branch: $(git branch --show-current)"
            echo "Remote: $(git remote get-url origin 2>/dev/null || echo 'Not configured')"
            echo ""
            git status
        else
            echo -e "${RED}Not a git repository${NC}"
        fi
        ;;
        
    help|--help|-h)
        echo "Bridge Template GitHub Sync"
        echo ""
        echo "Usage: $0 <command> [options]"
        echo ""
        echo "Commands:"
        echo "  init              Initialize git repository and setup GitHub"
        echo "  sync              Sync with GitHub (pull & push)"
        echo "  release [version] Create GitHub release"
        echo "  backup            Backup builds metadata to GitHub"
        echo "  setup             Setup GitHub remote"
        echo "  status            Show repository status"
        echo "  help              Show this help message"
        echo ""
        echo "Examples:"
        echo "  $0 init           # Initialize and setup GitHub"
        echo "  $0 sync           # Sync with GitHub"
        echo "  $0 release        # Create release for current version"
        echo "  $0 release 1.2.0  # Create release for specific version"
        ;;
        
    *)
        echo -e "${RED}Unknown command: $1${NC}"
        echo "Use '$0 help' for usage information"
        exit 1
        ;;
esac