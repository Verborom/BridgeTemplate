#!/bin/bash

# Bridge Template - Storage Cleanup Script
# Manages local storage by removing old builds and temporary files

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
KEEP_VERSIONS=3  # Number of versions to keep
DRY_RUN=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            echo -e "${YELLOW}DRY RUN MODE - No files will be deleted${NC}"
            ;;
        --keep)
            shift
            KEEP_VERSIONS="$1"
            ;;
        --help)
            echo "Usage: $0 [options]"
            echo "Options:"
            echo "  --dry-run       Show what would be deleted without deleting"
            echo "  --keep <n>      Number of versions to keep (default: 3)"
            echo "  --help          Show this help message"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
    shift
done

# Function to get directory size
get_size() {
    du -sh "$1" 2>/dev/null | cut -f1
}

# Function to remove directory
remove_dir() {
    local dir="$1"
    if [ "$DRY_RUN" = true ]; then
        echo -e "${YELLOW}[DRY RUN] Would remove: $dir${NC}"
    else
        rm -rf "$dir"
        echo -e "${GREEN}✓ Removed: $dir${NC}"
    fi
}

# Function to clean temporary files
clean_temp_files() {
    echo -e "\n${BLUE}Cleaning temporary files...${NC}"
    
    local temp_patterns=(
        "*.tmp"
        "*.temp"
        "*.log"
        ".DS_Store"
        "._*"
        "*.swp"
        "*.swo"
        "*~"
    )
    
    local count=0
    for pattern in "${temp_patterns[@]}"; do
        while IFS= read -r -d '' file; do
            if [ -f "$file" ]; then
                if [ "$DRY_RUN" = true ]; then
                    echo -e "${YELLOW}[DRY RUN] Would remove: $file${NC}"
                else
                    rm -f "$file"
                    ((count++))
                fi
            fi
        done < <(find "$PROJECT_ROOT" -name "$pattern" -type f -print0)
    done
    
    if [ "$DRY_RUN" = false ]; then
        echo -e "${GREEN}✓ Removed $count temporary files${NC}"
    fi
}

# Function to clean old build versions
clean_old_builds() {
    echo -e "\n${BLUE}Cleaning old build versions (keeping last $KEEP_VERSIONS)...${NC}"
    
    # Clean macOS builds
    if [ -d "$PROJECT_ROOT/builds/macos" ]; then
        echo -e "${YELLOW}Checking macOS builds...${NC}"
        cd "$PROJECT_ROOT/builds/macos"
        
        # Get all version directories sorted by version number
        local versions=($(ls -d v*/ 2>/dev/null | sort -V))
        local total=${#versions[@]}
        
        if [ $total -gt $KEEP_VERSIONS ]; then
            local to_remove=$((total - KEEP_VERSIONS))
            echo "Found $total versions, removing $to_remove old versions"
            
            for ((i=0; i<$to_remove; i++)); do
                local version="${versions[$i]}"
                local size=$(get_size "$version")
                echo -e "  ${version%/} (size: $size)"
                remove_dir "$version"
            done
        else
            echo "Found $total versions, no cleanup needed"
        fi
    fi
    
    # Clean iOS builds
    if [ -d "$PROJECT_ROOT/builds/ios" ]; then
        echo -e "\n${YELLOW}Checking iOS builds...${NC}"
        cd "$PROJECT_ROOT/builds/ios"
        
        # Get all version directories sorted by version number
        local versions=($(ls -d v*/ 2>/dev/null | sort -V))
        local total=${#versions[@]}
        
        if [ $total -gt $KEEP_VERSIONS ]; then
            local to_remove=$((total - KEEP_VERSIONS))
            echo "Found $total versions, removing $to_remove old versions"
            
            for ((i=0; i<$to_remove; i++)); do
                local version="${versions[$i]}"
                local size=$(get_size "$version")
                echo -e "  ${version%/} (size: $size)"
                remove_dir "$version"
            done
        else
            echo "Found $total versions, no cleanup needed"
        fi
    fi
    
    cd "$PROJECT_ROOT"
}

# Function to clean archive directory
clean_archive() {
    echo -e "\n${BLUE}Cleaning archive directory...${NC}"
    
    if [ -d "$PROJECT_ROOT/archive" ]; then
        # Keep archive directory but remove old files (older than 30 days)
        local count=0
        while IFS= read -r -d '' file; do
            if [ "$DRY_RUN" = true ]; then
                echo -e "${YELLOW}[DRY RUN] Would remove old archive: $(basename "$file")${NC}"
            else
                rm -f "$file"
                ((count++))
            fi
        done < <(find "$PROJECT_ROOT/archive" -type f -mtime +30 -print0)
        
        if [ "$DRY_RUN" = false ] && [ $count -gt 0 ]; then
            echo -e "${GREEN}✓ Removed $count old archive files${NC}"
        fi
    fi
}

# Function to clean build artifacts
clean_build_artifacts() {
    echo -e "\n${BLUE}Cleaning build artifacts...${NC}"
    
    # Swift Package Manager
    if [ -d "$PROJECT_ROOT/src/shared/.build" ]; then
        local size=$(get_size "$PROJECT_ROOT/src/shared/.build")
        echo -e "  Swift PM cache: $size"
        remove_dir "$PROJECT_ROOT/src/shared/.build"
    fi
    
    # Xcode DerivedData (local)
    local derived_data_paths=(
        "$PROJECT_ROOT/src/macos/DerivedData"
        "$PROJECT_ROOT/src/ios/DerivedData"
        "$PROJECT_ROOT/src/macos/build"
        "$PROJECT_ROOT/src/ios/build"
    )
    
    for path in "${derived_data_paths[@]}"; do
        if [ -d "$path" ]; then
            local size=$(get_size "$path")
            echo -e "  $(basename "$(dirname "$path")")/$(basename "$path"): $size"
            remove_dir "$path"
        fi
    done
}

# Function to show disk usage summary
show_disk_usage() {
    echo -e "\n${BLUE}Disk Usage Summary${NC}"
    echo -e "${BLUE}==================${NC}"
    
    local dirs=(
        "src"
        "builds"
        "temp"
        "archive"
        "docs"
        "scripts"
    )
    
    local total_size=0
    for dir in "${dirs[@]}"; do
        if [ -d "$PROJECT_ROOT/$dir" ]; then
            local size=$(du -sk "$PROJECT_ROOT/$dir" 2>/dev/null | cut -f1)
            local human_size=$(get_size "$PROJECT_ROOT/$dir")
            printf "%-15s %10s\n" "$dir:" "$human_size"
            total_size=$((total_size + size))
        fi
    done
    
    echo -e "${BLUE}------------------${NC}"
    local human_total=$(echo "$total_size" | awk '{printf "%.1f MB", $1/1024}')
    printf "%-15s %10s\n" "Total:" "$human_total"
}

# Main cleanup process
echo -e "${GREEN}Bridge Template Storage Cleanup${NC}"
echo -e "${GREEN}===============================${NC}"

# Show initial disk usage
echo -e "\n${YELLOW}Initial disk usage:${NC}"
show_disk_usage

# Perform cleanup
clean_temp_files
clean_old_builds
clean_archive
clean_build_artifacts

# Show final disk usage
if [ "$DRY_RUN" = false ]; then
    echo -e "\n${YELLOW}Final disk usage:${NC}"
    show_disk_usage
fi

echo -e "\n${GREEN}Cleanup completed!${NC}"

# Create .gitkeep files to preserve empty directories
if [ "$DRY_RUN" = false ]; then
    touch "$PROJECT_ROOT/temp/.gitkeep" 2>/dev/null || true
    touch "$PROJECT_ROOT/archive/.gitkeep" 2>/dev/null || true
fi